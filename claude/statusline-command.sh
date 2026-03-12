#!/usr/bin/env bash

# Tokyo Night / Catppuccin palette — $'\033[...]' syntax required for printf %s safety
# blue    111  #82aaff  — model name
# mauve   183  #c099ff  — session duration
# green   114  #c3e88d  — healthy / lots of time / low ctx
# yellow  221  #ffc777  — warning
# red     210  #ff757f  — critical
# dim     245  muted    — labels, separators, "used" text
C_BLUE=$'\033[38;5;111m'
C_MAUVE=$'\033[38;5;183m'
C_GREEN=$'\033[38;5;114m'
C_YELLOW=$'\033[38;5;221m'
C_RED=$'\033[38;5;210m'
C_DIM=$'\033[38;5;245m'
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'

SEP="${C_DIM} · ${C_RESET}"

input=$(cat)

# ── 1. Model ──────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
model="${model#Claude }"   # "Claude Sonnet 4.6" → "Sonnet 4.6"
model_part="${C_DIM}✦${C_RESET} ${C_BLUE}${C_BOLD}${model}${C_RESET}"

# ── 2. Context bar ────────────────────────────────────────────────────────────
ctx_part=""
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    bar_color="$C_RED"
  elif [ "$used_int" -ge 50 ]; then
    bar_color="$C_YELLOW"
  else
    bar_color="$C_GREEN"
  fi
  filled=$(( used_int * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  for _ in $(seq 1 "$filled"); do bar="${bar}▓"; done
  for _ in $(seq 1 "$empty");  do bar="${bar}░"; done
  ctx_part="${SEP}${bar_color}${bar} ${C_BOLD}${used_int}%${C_RESET}"
fi

# ── 3. Lines added / removed ─────────────────────────────────────────────────
lines_part=""
lines_added=$(echo "$input"   | jq -r '.cost.total_lines_added   // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
  lines_part="${SEP}${C_GREEN}${C_BOLD}+${lines_added}${C_RESET} ${C_RED}${C_BOLD}-${lines_removed}${C_RESET}"
fi

# ── 4. Timing (5-hour window + session) ──────────────────────────────────────
# The transcript file is created when the Claude Code session opens;
# its birth time anchors both the 5-hour usage window and the session clock.
window_part=""
session_part=""
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  # macOS birth time (epoch)
  session_start=$(stat -f "%SB" -t "%s" "$transcript" 2>/dev/null)
  if [ -z "$session_start" ]; then
    # Linux: prefer birth (%W), fall back to mtime (%Y)
    session_start=$(stat -c "%W" "$transcript" 2>/dev/null)
    if [ "$session_start" = "0" ] || [ -z "$session_start" ]; then
      session_start=$(stat -c "%Y" "$transcript" 2>/dev/null)
    fi
  fi

  if [ -n "$session_start" ] && [ "$session_start" -gt 0 ] 2>/dev/null; then
    now=$(date +%s)
    elapsed=$(( now - session_start ))

    # 5-hour window: show "Xh Ym used  Zh Wm left"
    window_secs=18000   # 5 * 3600
    remaining=$(( window_secs - elapsed ))

    # -- used time string
    u_total=$(( elapsed / 60 ))
    u_hrs=$(( u_total / 60 ))
    u_mins=$(( u_total % 60 ))
    if [ "$u_hrs" -gt 0 ]; then
      u_str=$(printf "%dh %02dm" "$u_hrs" "$u_mins")
    else
      u_str=$(printf "%dm" "$u_mins")
    fi

    if [ "$remaining" -le 0 ]; then
      window_part="${SEP}${C_GREEN}${C_BOLD}⚡ reset ready${C_RESET}"
    else
      # -- remaining time string + colour
      r_total=$(( remaining / 60 ))
      r_hrs=$(( r_total / 60 ))
      r_mins=$(( r_total % 60 ))
      if [ "$remaining" -le 900 ]; then          # <15 min
        r_color="$C_RED"
      elif [ "$remaining" -le 3600 ]; then        # <1 h
        r_color="$C_YELLOW"
      else
        r_color="$C_GREEN"
      fi
      if [ "$r_hrs" -gt 0 ]; then
        r_str=$(printf "%dh %02dm" "$r_hrs" "$r_mins")
      else
        r_str=$(printf "%dm" "$r_mins")
      fi
      window_part="${SEP}${C_DIM}⚡${C_RESET} ${r_color}${C_BOLD}${r_str} left${C_RESET}"
    fi

    # Session duration (same elapsed time, different framing)
    s_hrs=$(( elapsed / 3600 ))
    s_mins=$(( (elapsed % 3600) / 60 ))
    if [ "$s_hrs" -gt 0 ]; then
      s_str=$(printf "%dh %02dm" "$s_hrs" "$s_mins")
    else
      s_str=$(printf "%dm" "$s_mins")
    fi
    session_part="${SEP}${C_DIM}󰔛 ${C_RESET}${C_MAUVE}${C_BOLD}${s_str}${C_RESET}"
  fi
fi

# ── Output (single line, no trailing newline issues) ──────────────────────────
printf "%s%s%s%s%s" \
  "$model_part" "$ctx_part" "$lines_part" "$window_part" "$session_part"
