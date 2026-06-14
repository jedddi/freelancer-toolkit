#!/usr/bin/env bash
# quality-check.sh
# PostToolUse hook: after Claude writes or edits a content file, check its
# quality — warn on low word count and flag placeholder text.
#
# Reads the hook payload as JSON on stdin. Surfaces warnings to Claude by
# printing to stderr and exiting 2 (non-fatal: the tool has already run).

set -u

# --- Read hook input from stdin ---------------------------------------------
input="$(cat)"

# --- Extract the edited file path (jq if available, sed fallback) -----------
if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
else
  file_path="$(printf '%s' "$input" \
    | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n 1 \
    | sed 's/.*:[[:space:]]*"\(.*\)"/\1/')"
fi

# Nothing to check.
[ -z "$file_path" ] && exit 0

# --- Only inspect content files ---------------------------------------------
case "$file_path" in
  *.md|*.txt|*.html) ;;
  *) exit 0 ;;
esac

# Skip if the file isn't present/readable (e.g. it was deleted).
[ -f "$file_path" ] || exit 0

warnings=()

# --- Word count -------------------------------------------------------------
word_count="$(wc -w < "$file_path" | tr -d '[:space:]')"
word_count="${word_count:-0}"
if [ "$word_count" -lt 200 ]; then
  warnings+=("Low word count: ${word_count} words (under 200). Consider expanding the content.")
fi

# --- Placeholder text (case-insensitive: 'lorem ipsum', 'TODO') -------------
if grep -qiE 'lorem ipsum|TODO' "$file_path"; then
  matches="$(grep -niE 'lorem ipsum|TODO' "$file_path" | head -n 5)"
  warnings+=("Placeholder text found:"$'\n'"${matches}")
fi

# --- Report -----------------------------------------------------------------
if [ "${#warnings[@]}" -gt 0 ]; then
  {
    echo "⚠️  Content quality check — ${file_path}"
    for w in "${warnings[@]}"; do
      echo "  - ${w}"
    done
  } >&2
  exit 2
fi

exit 0
