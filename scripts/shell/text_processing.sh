#!/bin/sh
# Example: Text processing pipeline with awk, sed, grep

INPUT="${1:-data/raw/input.txt}"
OUTPUT="${2:-data/output/processed.txt}"

echo "🔧 Text processing pipeline..."

# Example pipeline - modify as needed
cat "$INPUT" | \
  # Remove empty lines
  sed '/^$/d' | \
  # Remove comments (lines starting with #)
  grep -v '^#' | \
  # Extract specific pattern (example: email addresses)
  grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}' | \
  # Convert to lowercase
  tr '[:upper:]' '[:lower:]' | \
  # Sort and remove duplicates
  sort -u \
  > "$OUTPUT"

echo "✅ Processed $(wc -l < "$OUTPUT") unique items"
echo "   Output: $OUTPUT"
