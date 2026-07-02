#!/bin/bash
# Search Events directory for matching event
# Usage: search_events_dir.sh "2026-07-07" OR search_events_dir.sh "GenAI Day"

set -e

QUERY="$1"
EVENTS_DIR="/Users/michael/repos/Events"

if [[ -z "$QUERY" ]]; then
  echo "Usage: search_events_dir.sh \"DATE_OR_NAME\""
  echo "Example: search_events_dir.sh \"2026-07-07\""
  echo "Example: search_events_dir.sh \"GenAI Day\""
  exit 1
fi

if [[ ! -d "$EVENTS_DIR" ]]; then
  echo "Events directory not found: $EVENTS_DIR"
  exit 1
fi

# Search for directories matching the query
# Try date match first (YYYY-MM-DD at start of directory name)
MATCHES=()

# Match by date (directory starts with YYYY-MM-DD)
if [[ $QUERY =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  while IFS= read -r -d '' dir; do
    MATCHES+=("$dir")
  done < <(find "$EVENTS_DIR" -maxdepth 1 -type d -name "${QUERY}*" -print0)
fi

# Match by name (case-insensitive, anywhere in directory name)
while IFS= read -r -d '' dir; do
  # Avoid duplicates
  if [[ ! " ${MATCHES[@]} " =~ " $dir " ]]; then
    MATCHES+=("$dir")
  fi
done < <(find "$EVENTS_DIR" -maxdepth 1 -type d -iname "*${QUERY}*" -print0)

# Output results
if [[ ${#MATCHES[@]} -eq 0 ]]; then
  echo "No events found matching: $QUERY"
  exit 1
elif [[ ${#MATCHES[@]} -eq 1 ]]; then
  echo "Found: $(basename "${MATCHES[0]}")"
else
  echo "Found ${#MATCHES[@]} matches:"
  for i in "${!MATCHES[@]}"; do
    echo "$((i+1)). $(basename "${MATCHES[$i]}")"
  done
fi
