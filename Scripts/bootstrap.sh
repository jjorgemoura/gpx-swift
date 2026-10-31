#!/usr/bin/env bash
#
# bootstrap.sh — turn a fresh copy of swift-library-template into a real library.
# Run once, from the root of the new repo, then commit. The script deletes itself.
#
# Usage:
#   scripts/bootstrap.sh <repo-name> <ModuleName> <github-owner> ["Copyright Holder"]
#   scripts/bootstrap.sh gpx-swift GPXSwift my-user "Jorge ..."
#
# Replaces, in file contents AND in file/folder names:
#   LibraryTemplate       -> <ModuleName>     (module, types, Demo project, scheme)
#   library-template      -> <repo-name>
#   __OWNER__             -> <github-owner>
#   __YEAR__              -> current year
#   __COPYRIGHT_HOLDER__  -> holder (default: git config user.name)
#
# Uses perl for in-place edits so it behaves the same on macOS and Linux.

set -euo pipefail

if [[ $# -lt 3 ]]; then
  sed -n '2,17p' "$0"
  exit 1
fi

REPO="$1"
MODULE="$2"
OWNER="$3"
HOLDER="${4:-$(git config user.name || true)}"
YEAR="$(date +%Y)"

[[ "$REPO"   =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "repo-name must be kebab-case" >&2; exit 1; }
[[ "$MODULE" =~ ^[A-Z][A-Za-z0-9]*$ ]]       || { echo "ModuleName must be UpperCamelCase" >&2; exit 1; }
[[ -n "$HOLDER" ]]                           || { echo "copyright holder missing" >&2; exit 1; }
[[ -f Package.swift && -d Sources/LibraryTemplate ]] || {
  echo "run from the root of an un-bootstrapped template copy" >&2; exit 1; }

export REPO MODULE OWNER HOLDER YEAR

# 1. File contents (text files only, skip .git).
while IFS= read -r -d '' f; do
  perl -pi -e '
    s/LibraryTemplate/$ENV{MODULE}/g;
    s/library-template/$ENV{REPO}/g;
    s/__OWNER__/$ENV{OWNER}/g;
    s/__YEAR__/$ENV{YEAR}/g;
    s/__COPYRIGHT_HOLDER__/$ENV{HOLDER}/g;
  ' "$f"
done < <(grep -rlIZ --exclude-dir=.git -e LibraryTemplate -e library-template \
           -e __OWNER__ -e __YEAR__ -e __COPYRIGHT_HOLDER__ . || true)

# 2. File and folder names, deepest first so parents are renamed last.
while IFS= read -r -d '' path; do
  base="$(basename "$path")"
  new="${base//LibraryTemplate/$MODULE}"
  [[ "$new" != "$base" ]] && mv "$path" "$(dirname "$path")/$new"
done < <(find . -depth -name '*LibraryTemplate*' -not -path './.git/*' -print0)

# 3. Remove template-only files.
rm -f TEMPLATE.md
rm -f "$0"
rmdir scripts 2>/dev/null || true

# 4. Fail loudly if anything was missed.
if grep -rnI --exclude-dir=.git -e LibraryTemplate -e library-template -e __OWNER__ \
     -e __YEAR__ -e __COPYRIGHT_HOLDER__ . ; then
  echo "error: placeholders left (see above)" >&2
  exit 1
fi

echo "Bootstrapped $REPO ($MODULE). Review with 'git status', then commit."
