#!/usr/bin/env bash
# Build from manually maintained Pi-hole Gravity exports. No upstream downloads.
set -euo pipefail
export LC_ALL=C
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $# != 1 ]]; then
  echo "Usage: bash scripts/build-masterlist.sh OUTPUT_DIRECTORY" >&2
  exit 2
fi
mkdir -p -- "$1"
out=$(cd -- "$1" && pwd)
# Protect against accidentally creating the oversized file in the repo root.
if [[ "$out" == "$root" ]]; then
  echo 'Choose an output directory other than the repository root.' >&2
  exit 2
fi
cd "$root"
shopt -s nullglob
parts=(masterlist-part-*.txt)
if (( ${#parts[@]} < 2 )); then
  echo 'Expected at least two masterlist-part-*.txt files in the repository root.' >&2
  exit 1
fi
for required in masterlist-part-0.txt masterlist-part-1.txt; do
  if [[ ! -s "$required" ]]; then
    echo "Missing or empty required file: $required" >&2
    exit 1
  fi
done
for part in "${parts[@]}"; do
  if [[ ! -s "$part" ]]; then
    echo "Empty part: $part" >&2
    exit 1
  fi
  size=$(wc -c < "$part")
  if (( size >= 100 * 1024 * 1024 )); then
    echo "Part too large for GitHub: $part ($size bytes). Split it again." >&2
    exit 1
  fi
done
work=$(mktemp -d "$out/.build.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
# Preserve exact entries (including any Pi-hole-supported rule syntax).
# Remove CRLF carriage returns and blank lines; do not reinterpret domains.
awk '{sub(/\r$/, ""); if ($0 !~ /^[[:space:]]*$/) print}' "${parts[@]}" > "$work/input.txt"
input_count=$(wc -l < "$work/input.txt")
sort -u "$work/input.txt" > "$work/masterlist.txt"
unique_count=$(wc -l < "$work/masterlist.txt")
if (( unique_count == 0 )); then
  echo 'Refusing to publish an empty list.' >&2
  exit 1
fi
sort -c -u "$work/masterlist.txt"
bytes=$(wc -c < "$work/masterlist.txt")
if (( bytes >= 2 * 1024 * 1024 * 1024 )); then
  echo 'Master list exceeds the release asset size limit.' >&2
  exit 1
fi
(
  cd "$work"
  sha256sum masterlist.txt > masterlist.txt.sha256
  sha256sum -c masterlist.txt.sha256
)
{
  printf 'Combined, sorted and deduplicated master blocklist.\n\n'
  printf -- '- Source parts: %s\n' "${#parts[@]}"
  printf -- '- Input entries (nonblank): %s\n' "$input_count"
  printf -- '- Exact duplicates removed: %s\n' "$((input_count - unique_count))"
  printf -- '- Published unique entries: %s\n' "$unique_count"
  printf -- '- File size: %s bytes\n' "$bytes"
  printf -- '- Source commit: %s\n' "${GITHUB_SHA:-local build}"
  printf '\nOnly the manually maintained repository files are used.\n'
} > "$work/release-notes.md"
for file in masterlist.txt masterlist.txt.sha256 release-notes.md; do
  mv -- "$work/$file" "$out/$file"
done
cat "$out/release-notes.md"
