---
name: lambda
description: Genera AWS Lambda functions en TypeScript production-ready con estructura correcta, tipos del SDK v3, validación con Zod, logging estructurado, cold start optimization, manejo de errores y permisos IAM mínimos.
argument-hint: [trigger: api|sqs|s3|scheduled|sns] [descripción de qué hace]
---

Crea una AWS Lambda function para: $ARGUMENTS

Primero determina:
- **Trigger**: APIGateway REST/HTTP, SQS, S3, EventBridge, SNS, DynamoDB Streams
- **Runtime context**: ¿accede a DB? ¿llama a servicios externos? ¿escribe a S3?
- **Idempotencia**: ¿puede ejecutarse dos veces sin daño? (SQS/SNS pueden re-entregar)

---

## ESTRUCTURA DE ARCHIVOS

```
src/
  handler.ts          # Entry point — thin, solo orquesta
  service.ts          # Lógica de negocio pura — testeable sin AWS
  repository.ts       # Acceso a datos — si hay DB o S3
  types.ts            # Tipos del evento, respuesta, dominio
  errors.ts           # Errores de dominio tipados
  schema.ts           # Schemas de validación Zod
handler.test.ts       # Tests del handler con mocks
service.test.ts       # Tests del service sin mocks de AWS
```

---

## HANDLER — siempre así de delgado

```typescript
import { APIGatewayProxyHandlerV2 } from 'aws-lambda'
import { ZodError } from 'zod'
import { UserService } from './service'
import { CreateUserSchema } from './schema'
import { DomainError } from './errors'

// ✅ Clientes inicializados FUERA del handler (sobreviven entre invocaciones)
const userService = new UserService()

export const handler: APIGatewayProxyHandlerV2 = async (event, context) => {
  const log = (level: string, msg: string, extra?: object) =>
    console.log(JSON.stringify({ level, msg, requestId: context.awsRequestId, ...extra }))

  log('info', 'Request received', {
    method: event.requestContext.http.method,
    path: event.rawPath,
    // ⚠️ Nunca loggear body completo si puede tener datos sensibles
  })

  try {
    // 1. Parsear y validar input
    const body = JSON.parse(event.body ?? '{}')
    const input = CreateUserSchema.parse(body)

    // 2. Ejecutar lógica de negocio
    const result = await userService.createUser(input)

    log('info', 'Request completed', { userId: result.id })

    return {
      statusCode: 201,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result),
    }
  } catch (error) {
    if (error instanceof ZodError) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Validation failed', details: error.flatten() }),
      }
    }

    if (error instanceof DomainError) {
      log('warn', 'Domain error', { code: error.code, message: error.message })
      return {
        statusCode: error.httpStatus,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: error.message, code: error.code }),
      }
    }

    // Error inesperado — nunca exponer detalles al cliente
    log('error', 'Unexpected error', { error: String(error) })
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Internal server error' }),
    }
  }
}
```

---

## TIPOS POR TRIGGER

```typescript
// API Gateway HTTP v2
import type { APIGatewayProxyHandlerV2, APIGatewayProxyEventV2 } from 'aws-lambda'

// SQS — recordar: debe procesar cada record y reportar failures parciales
import type { SQSHandler, SQSEvent, SQSBatchResponse } from 'aws-lambda'
// SQS retorna SQSBatchResponse con itemIdentifier de los que fallaron

// S3
import type { S3Handler, S3Event } from 'aws-lambda'

// EventBridge / Scheduled
import type { EventBridgeHandler, ScheduledHandler } from 'aws-lambda'

// DynamoDB Streams
import type { DynamoDBStreamHandler } from 'aws-lambda'
```

---

## REGLAS CRÍTICAS

**Cold start:**
```typescript
// ✅ Fuera del handler — se inicializa UNA vez
import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb'

const ddbClient = new DynamoDBClient({ region: process.env.AWS_REGION })
const ddb = DynamoDBDocumentClient.from(ddbClient)

// ❌ Dentro del handler — se re-inicializa en cada invocación
export const handler = async () => {
  const ddb = new DynamoDBClient({}) // MAL
}
```

**SDK v3 — siempre importar por módulo específico:**
```typescript
// ✅ Tree-shaking correcto
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'

// ❌ Importa todo el SDK (bundle enorme)
import AWS from 'aws-sdk'
```

**Idempotencia en SQS:**
```typescript
// SQS puede re-entregar mensajes. El handler DEBE ser idempotente.
// Usar messageId como idempotency key en writes a DB
const { messageId } = record

// Reportar failures parciales correctamente:
const failures: SQSBatchResponse['batchItemFailures'] = []
for (const record of event.Records) {
  try {
    await processRecord(record)
  } catch {
    failures.push({ itemIdentifier: record.messageId })
  }
}
return { batchItemFailures: failures }
```

**Variables de entorno — nunca hardcodear:**
```typescript
// types.ts — validar al inicio, fallar rápido si falta algo
const ENV = {
  tableName: process.env.TABLE_NAME!,
  bucketName: process.env.BUCKET_NAME!,
} as const

// Validar en tiempo de inicialización, no durante la invocación
if (!ENV.tableName) throw new Error('TABLE_NAME env var required')
```

---

## ERRORES DE DOMINIO

```typescript
// errors.ts
export class DomainError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly httpStatus: number,
  ) {
    super(message)
    this.name = 'DomainError'
  }
}

export class NotFoundError extends DomainError {
  constructor(resource: string, id: string) {
    super(`${resource} ${id} not found`, 'NOT_FOUND', 404)
  }
}

export class ConflictError extends DomainError {
  constructor(message: string) {
    super(message, 'CONFLICT', 409)
  }
}
```

---

## ENTREGA

1. `handler.ts` — thin handler con logging y error handling
2. `service.ts` — lógica de negocio sin imports de AWS
3. `schema.ts` — validación Zod del input
4. `errors.ts` — errores de dominio tipados
5. `types.ts` — tipos del evento y respuesta
6. **Permisos IAM mínimos** necesarios (JSON de policy)
7. **Variables de entorno** requeridas con descripción
8. `service.test.ts` — tests unitarios sin mocks de AWS
9. **Notas de idempotencia** si el trigger puede re-entregar
