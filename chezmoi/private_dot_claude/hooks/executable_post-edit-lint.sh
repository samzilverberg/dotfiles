#!/usr/bin/env bash
# Post-edit lint hook: finds nearest package.json lint script, runs with --fix.
# Exits 0 always — never blocks Claude.

INPUT=$(cat)

# Extract edited file path — jq preferred, grep fallback
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '(.tool_input // .toolInput) | (.file_path // .filePath) // ""' 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(printf '%s' "$INPUT" | grep -oE '"file_path"\s*:\s*"[^"]*"' | head -1 | sed -E 's/"file_path"\s*:\s*"([^"]*)"/\1/')
fi

[ -z "$FILE_PATH" ] && exit 0

# Skip node_modules
case "$FILE_PATH" in
  */node_modules/*) exit 0 ;;
esac

# Only JS/TS/Vue files
case "$FILE_PATH" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.vue) ;;
  *) exit 0 ;;
esac

# Walk up to find package.json; stop at home dir or filesystem root
DIR=$(dirname "$FILE_PATH")
PKG_DIR=""
while [ "$DIR" != "/" ] && [ "$DIR" != "." ]; do
  if [ -f "$DIR/package.json" ]; then
    PKG_DIR="$DIR"
    break
  fi
  [ "$DIR" = "$HOME" ] && break
  DIR=$(dirname "$DIR")
done

[ -z "$PKG_DIR" ] && exit 0

# Check lint script exists (no python)
grep -qE '"lint"\s*:' "$PKG_DIR/package.json" 2>/dev/null || exit 0

# Detect package manager and build command
if [ -f "$PKG_DIR/package-lock.json" ]; then
  LINT_CMD="npm run lint -- --fix"
else
  LINT_CMD="pnpm run lint --fix"
fi

# Run lint, swallow all errors
cd "$PKG_DIR" && $LINT_CMD 2>/dev/null || true

exit 0
