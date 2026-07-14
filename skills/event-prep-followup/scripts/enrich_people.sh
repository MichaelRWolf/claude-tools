#!/bin/bash
# Query Contacts.app for person info and output RFC 6350 vCard
# Usage: enrich_people.sh "Kristen Walsh"
# Output: vCard format to stdout

set -e

PERSON_NAME="$1"

if [[ -z "$PERSON_NAME" ]]; then
  echo "Usage: enrich_people.sh \"Person Name\"" >&2
  exit 1
fi

# Query Contacts.app using osascript with 5-second timeout
QUERY_SCRIPT="
tell application \"Contacts\"
  activate
  try
    set theContact to first person whose name contains \"$PERSON_NAME\"
    set contactName to name of theContact
    set contactEmails to emails of theContact
    set contactPhones to phones of theContact
    set contactURLs to urls of theContact

    set emailList to {}
    repeat with anEmail in contactEmails
      set end of emailList to value of anEmail
    end repeat
    set emailStr to my joinList(emailList, \"~~~\")

    set phoneList to {}
    repeat with aPhone in contactPhones
      set end of phoneList to value of aPhone
    end repeat
    set phoneStr to my joinList(phoneList, \"~~~\")

    set urlList to {}
    repeat with aURL in contactURLs
      set end of urlList to value of aURL
    end repeat
    set urlStr to my joinList(urlList, \"~~~\")

    return contactName & \"|\" & emailStr & \"|\" & phoneStr & \"|\" & urlStr

  on joinList(theList, delim)
    set {oldTID, my text item delimiters} to {my text item delimiters, delim}
    set result to (theList as text)
    set my text item delimiters to oldTID
    return result
  end joinList
  on error
    return \"$PERSON_NAME|not_found|not_found|not_found\"
  end try
end tell
"

# Run with timeout (5 seconds)
RESULT=$(timeout 5 osascript -e "$QUERY_SCRIPT" 2>/dev/null || echo "$PERSON_NAME|timeout|timeout|timeout")

# Parse result
IFS='|' read -r NAME EMAILS PHONES URLS <<< "$RESULT"

# Generate vCard (RFC 6350)
# Include only non-empty fields
VCARD="BEGIN:VCARD
VERSION:4.0
FN:$NAME"

# Add all emails (~~~-delimited, convert to separate EMAIL fields)
if [[ "$EMAILS" != "not_found" && "$EMAILS" != "timeout" && -n "$EMAILS" ]]; then
  IFS='~~~' read -ra EMAIL_ARRAY <<< "$EMAILS"
  for email in "${EMAIL_ARRAY[@]}"; do
    [[ -n "$email" ]] && VCARD="$VCARD
EMAIL:$email"
  done
fi

# Add all phones (~~~-delimited, convert to separate TEL fields)
if [[ "$PHONES" != "not_found" && "$PHONES" != "timeout" && -n "$PHONES" ]]; then
  IFS='~~~' read -ra PHONE_ARRAY <<< "$PHONES"
  for phone in "${PHONE_ARRAY[@]}"; do
    [[ -n "$phone" ]] && VCARD="$VCARD
TEL:$phone"
  done
fi

# Add all URLs (~~~-delimited, convert to separate URL fields)
if [[ "$URLS" != "not_found" && "$URLS" != "timeout" && -n "$URLS" ]]; then
  IFS='~~~' read -ra URL_ARRAY <<< "$URLS"
  for url in "${URL_ARRAY[@]}"; do
    [[ -n "$url" ]] && VCARD="$VCARD
URL:$url"
  done
fi

VCARD="$VCARD
END:VCARD"

# Output vCard to stdout
echo "$VCARD"
