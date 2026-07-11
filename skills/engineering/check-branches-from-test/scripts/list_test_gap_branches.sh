#!/usr/bin/env bash

set -euo pipefail

BASE_BRANCH="${1:-origin/test}"
REF_PREFIX="${2:-origin/}"

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  printf 'Base branch not found: %s\n' "$BASE_BRANCH" >&2
  printf 'Usage: %s [base-branch] [ref-prefix]\n' "${0##*/}" >&2
  exit 1
fi

git branch -r --no-merged "$BASE_BRANCH" | while IFS= read -r branch; do
  branch="${branch#  }"

  case "$branch" in
    "$BASE_BRANCH"|"${REF_PREFIX}HEAD")
      continue
      ;;
  esac

  case "$branch" in
    "$REF_PREFIX"*)
      printf '%s\n' "$branch"
      ;;
  esac
done
