#!/usr/bin/env bash
# session-summary.sh
# Stop hook: when Claude finishes a session, print a concise summary of what
# was accomplished — files created/edited, commands run, and a tool-call
# breakdown — reconstructed from the session transcript.
#
# Reads the hook payload as JSON on stdin. Prints the summary to stdout and
# exits 0 (non-blocking: it never prevents Claude from stopping). Stop-hook
# stdout is surfaced in the transcript view (Ctrl-R).

set -u

# --- Read hook input from stdin ---------------------------------------------
input="$(cat)"

# --- Extract transcript_path and stop_hook_active (jq, sed fallback) --------
if command -v jq >/dev/null 2>&1; then
  have_jq=1
  transcript_path="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
  stop_active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false')"
else
  have_jq=0
  transcript_path="$(printf '%s' "$input" \
    | grep -o '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n 1 \
    | sed 's/.*:[[:space:]]*"\(.*\)"/\1/')"
  stop_active="$(printf '%s' "$input" \
    | grep -o '"stop_hook_active"[[:space:]]*:[[:space:]]*[a-z]*' \
    | head -n 1 \
    | sed 's/.*:[[:space:]]*//')"
fi

# Already inside a forced continuation triggered by a Stop hook — don't
# re-summarize on the follow-up stop.
[ "${stop_active:-false}" = "true" ] && exit 0

# --- Divider helper ---------------------------------------------------------
line="────────────────────────────────────────────"

# If there's no readable transcript, there's nothing to summarize.
if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  printf '%s\n📋 Session Summary\n%s\n  (no transcript available to summarize)\n%s\n' \
    "$line" "$line" "$line"
  exit 0
fi

# --- Gather activity from the transcript ------------------------------------
# Editing tools whose target counts as a "file changed".
edit_tools='Write|Edit|MultiEdit|NotebookEdit'

if [ "$have_jq" -eq 1 ]; then
  # Tool names, one per line (streamed — no full-file slurp).
  tool_names="$(jq -r '
    select(.type=="assistant")
    | .message.content[]?
    | select(.type=="tool_use")
    | .name' "$transcript_path" 2>/dev/null)"

  # Distinct files created/edited.
  edited_files="$(jq -r --arg t "Write Edit MultiEdit NotebookEdit" '
    select(.type=="assistant")
    | .message.content[]?
    | select(.type=="tool_use" and (.name as $n | ($t | split(" ")) | index($n)))
    | .input.file_path // empty' "$transcript_path" 2>/dev/null | sort -u)"
else
  # Fallback: best-effort grep over the raw JSONL. Claude Code writes one
  # tool_use per line, so we scope extraction to those lines — names come
  # from every tool_use; file paths only from the editing tools.
  tool_use_lines="$(grep -E '"type"[[:space:]]*:[[:space:]]*"tool_use"' "$transcript_path" 2>/dev/null)"
  tool_names="$(printf '%s\n' "$tool_use_lines" \
    | grep -oE '"name"[[:space:]]*:[[:space:]]*"[A-Za-z_]+"' \
    | sed -E 's/.*"([A-Za-z_]+)"$/\1/')"
  edited_files="$(printf '%s\n' "$tool_use_lines" \
    | grep -E "\"name\"[[:space:]]*:[[:space:]]*\"(${edit_tools})\"" \
    | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed -E 's/.*"file_path"[[:space:]]*:[[:space:]]*"(.*)"$/\1/' \
    | sort -u)"
fi

# --- Tally ------------------------------------------------------------------
total_tools="$(printf '%s\n' "$tool_names" | grep -c . || true)"
bash_count="$(printf '%s\n' "$tool_names" | grep -cx 'Bash' || true)"
file_count="$(printf '%s\n' "$edited_files" | grep -c . || true)"
breakdown="$(printf '%s\n' "$tool_names" | grep . | sort | uniq -c | sort -rn \
  | awk '{ printf "%s%s×%s", sep, $1, $2; sep=", " } END { print "" }')"

# --- Print the summary ------------------------------------------------------
{
  echo "$line"
  echo "📋 Session Summary"
  echo "$line"

  if [ "$file_count" -gt 0 ]; then
    echo "Files created/edited (${file_count}):"
    printf '%s\n' "$edited_files" | grep . | while IFS= read -r f; do
      echo "  • ${f}"
    done
  else
    echo "Files created/edited: none"
  fi

  echo "Commands run: ${bash_count}"

  if [ "$total_tools" -gt 0 ]; then
    echo "Tool calls: ${total_tools} (${breakdown})"
  else
    echo "Tool calls: none — nothing was changed this session"
  fi

  echo "$line"
}

exit 0
