#!/usr/bin/env bash

set -e

OUT="all_ruby_sources.txt"
> "$OUT"

echo "### Ruby sources dump ($(date))" >> "$OUT"
echo >> "$OUT"

find . -type f -name "*.rb" | sort | while read -r file; do
  echo "===== FILE: $file =====" >> "$OUT"
  echo >> "$OUT"
  cat "$file" >> "$OUT"
  echo >> "$OUT"
  echo >> "$OUT"
done

echo "Wrote $OUT"
