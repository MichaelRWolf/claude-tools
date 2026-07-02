#!/bin/bash
# Create a basic .ics (iCalendar) file for an event
# Usage: create_ics.sh "2026-07-07" "GenAI Day" "9:00 AM" "description"

set -e

DATE="$1"
TITLE="$2"
TIME="${3:-9:00 AM}"
DESCRIPTION="${4:-}"

if [[ -z "$DATE" ]] || [[ -z "$TITLE" ]]; then
  echo "Usage: create_ics.sh \"DATE\" \"TITLE\" [TIME] [DESCRIPTION]"
  echo "Example: create_ics.sh \"2026-07-07\" \"GenAI Day\" \"9:00 AM\" \"Workshop on AI\""
  exit 1
fi

# Parse date and time into iCalendar format
# Input: "2026-07-07" and "9:00 AM"
# Output: "20260707T090000Z" (UTC format for simplicity)

# Convert date to YYYYMMDD format
DATE_FORMATTED="${DATE//-/}"

# Parse time (simplified: assumes HH:MM AM/PM)
if [[ $TIME =~ ([0-9]{1,2}):([0-9]{2})\ (AM|PM) ]]; then
  HOUR="${BASH_REMATCH[1]}"
  MIN="${BASH_REMATCH[2]}"
  AMPM="${BASH_REMATCH[3]}"

  # Convert to 24-hour format
  if [[ "$AMPM" == "PM" ]] && [[ "$HOUR" != "12" ]]; then
    HOUR=$((HOUR + 12))
  elif [[ "$AMPM" == "AM" ]] && [[ "$HOUR" == "12" ]]; then
    HOUR="00"
  fi

  TIME_FORMATTED=$(printf "%02d%02d00" "$HOUR" "$MIN")
else
  # Default to 9:00 AM if parsing fails
  TIME_FORMATTED="090000"
fi

DTSTART="${DATE_FORMATTED}T${TIME_FORMATTED}"
DTSTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
UID="$(date +%s)@example.com"

# Create .ics file
cat > "/tmp/${DATE}_${TITLE// /_}.ics" <<EOF
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Michael Wolf//Event Calendar//EN
CALSCALE:GREGORIAN
BEGIN:VEVENT
DTSTART:${DTSTART}
DTSTAMP:${DTSTAMP}
DTEND:${DTSTART}
SUMMARY:${TITLE}
DESCRIPTION:${DESCRIPTION}
UID:${UID}
END:VEVENT
END:VCALENDAR
EOF

ICS_FILE="/tmp/${DATE}_${TITLE// /_}.ics"
echo "Created: $ICS_FILE"
echo "Opening in Calendar.app..."

open "$ICS_FILE"
