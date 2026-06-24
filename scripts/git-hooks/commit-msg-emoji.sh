#!/bin/sh
# prepare-commit-msg hook: prepend a type emoji to the commit message.
# Decorative only. It never blocks a commit (commit-msg-lint.sh enforces format).
# Args from Git: $1 = path to commit message file, $2 = commit source.
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only touch hand-written commits. Skip auto-generated messages:
#   merge  -> merge commit ("Merge branch ...")
#   squash -> squashed/fixup message during rebase
[ "$COMMIT_SOURCE" = "merge" ] && exit 0
[ "$COMMIT_SOURCE" = "squash" ] && exit 0

MSG=$(cat "$COMMIT_MSG_FILE")

# Idempotent: if the message already starts with an emoji, do nothing.
# (Covers amends and re-edits so we never stack two emojis.)
echo "$MSG" | grep -qP '^[\x{1F000}-\x{1FFFF}]' 2>/dev/null || \
echo "$MSG" | grep -q '^[🎉✨🐛🔨📦🔧👷📝💄♻️⚡🧪⏪🚀🔒💥]' && exit 0

# Pick an emoji from the Conventional Commit type prefix.
# Type = the kind of change. Use the one that matches your intent:
case "$MSG" in
  feat*)     EMOJI="✨" ;;  # new feature or capability for users
  fix*)      EMOJI="🐛" ;;  # bug fix: wrong behavior now corrected
  build*)    EMOJI="📦" ;;  # build system / dependencies (pubspec, gradle)
  chore*)    EMOJI="🔧" ;;  # housekeeping: configs, tooling, no app code change
  ci*)       EMOJI="👷" ;;  # CI/CD pipelines, workflows, automation
  docs*)     EMOJI="📝" ;;  # documentation only (README, docs/, comments)
  style*)    EMOJI="💄" ;;  # formatting/whitespace only, no logic change
  refactor*) EMOJI="♻️" ;;  # restructure code, same behavior (not feat, not fix)
  perf*)     EMOJI="⚡" ;;  # performance improvement
  test*)     EMOJI="🧪" ;;  # add or fix tests only
  revert*)   EMOJI="⏪" ;;  # undo a previous commit
  release*)  EMOJI="🚀" ;;  # version bump / publish a release
  security*) EMOJI="🔒" ;;  # security fix or hardening
  update*)   EMOJI="⬆️" ;;  # bump dependencies / upgrade versions
  *)         exit 0 ;;      # unknown type: leave message untouched, do not block
esac

# Write the message back with the emoji prepended.
echo "$EMOJI $MSG" > "$COMMIT_MSG_FILE"
