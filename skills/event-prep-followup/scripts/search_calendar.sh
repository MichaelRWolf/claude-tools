#!/bin/bash
# Search Calendar.app for events matching a date or name
# Usage: search_calendar.sh "2026-07-07" OR search_calendar.sh "GenAI Day"

set -e

QUERY="$1"

if [[ -z "$QUERY" ]]; then
  echo "Usage: search_calendar.sh \"DATE_OR_NAME\""
  echo "Example: search_calendar.sh \"2026-07-07\""
  echo "Example: search_calendar.sh \"GenAI Day\""
  exit 1
fi

# Use AppleScript to query Calendar.app
osascript <<EOF
tell application "Calendar"
  activate
  set searchResults to {}
  set allCalendars to calendars

  repeat with cal in allCalendars
    set allEvents to (every event of cal)
    repeat with evt in allEvents
      set eventTitle to summary of evt
      set eventDate to start date of evt
      set eventDateStr to (eventDate as text)

      -- Match by name (case-insensitive)
      if eventTitle contains "$QUERY" or eventDateStr contains "$QUERY" then
        set end of searchResults to {title:eventTitle, date:eventDateStr, event:evt}
      end if
    end repeat
  end repeat

  -- Return results as text
  if searchResults is not {} then
    set output to ""
    repeat with result in searchResults
      set output to output & (title of result) & " | " & (date of result) & linefeed
    end repeat
    return output
  else
    return "No events found matching: $QUERY"
  end if
end tell
EOF
