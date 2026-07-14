# Event Prep & Follow-up -- Helper Scripts

Utility scripts for event discovery and file creation. These support the interactive skill workflows.

## Scripts

### search_events_dir.sh

Search `/Users/michael/repos/Events/` for matching event directories.

```bash
./search_events_dir.sh "2026-07-07"
./search_events_dir.sh "GenAI Day"
./search_events_dir.sh "Kristen"
```

**Output:**

```text
Found: 2026-07-07_GenAI_Day_7
```

Or if multiple matches:

```text
Found 2 matches:
1. 2026-07-07_GenAI_Day_7
2. 2026-07-07_Team_Standup
```

### search_calendar.sh

Search Calendar.app for events matching a date or name.

```bash
./search_calendar.sh "2026-07-07"
./search_calendar.sh "GenAI Day"
```

**Note:** Requires Calendar.app to be available (macOS only).

### create_ics.sh

Create a basic .ics (iCalendar) file and open it in Calendar.app.

```bash
./create_ics.sh "2026-07-07" "GenAI Day" "9:00 AM" "Workshop on AI"
./create_ics.sh "2026-07-15" "Coffee with Alan"
```

**Output:**

- Creates `/tmp/2026-07-07_GenAI_Day.ics`
- Opens it in Calendar.app
- User confirms and comes back to complete prep

### enrich_people.sh

Query Contacts.app and output RFC 6350 vCard format (with 5-second timeout). Single person per call; caller handles file I/O.

```bash
./enrich_people.sh "Kristen Walsh"
./enrich_people.sh "Marie Chen" > /path/to/Marie_Chen.vcf
```

**vCard output:**

```vcard
BEGIN:VCARD
VERSION:4.0
FN:Jess Wolfe
EMAIL:jess@swarmia.com
TEL:+1-555-5678
URL:https://www.linkedin.com/in/thejessicawolfe/
END:VCARD
```

Only non-empty fields included. Email, phone, and URLs extracted from Contacts.app; missing fields simply omitted.

**Timeout handling:**

If Contacts.app doesn't respond within 5 seconds, returns minimal vCard with just name:

```vcard
BEGIN:VCARD
VERSION:4.0
FN:Kristen Walsh
END:VCARD
```

Workflow continues; user can augment vCard files manually later.

## Integration

The skill calls these scripts when:

1. **prep for [date/event]** → Searches Events dir and Calendar.app via `search_events_dir.sh` and `search_calendar.sh`
2. **Missing calendar entry?** → Offers to create .ics file via `create_ics.sh`
3. **followup for [event]** → Searches Events dir for existing event via `search_events_dir.sh`
4. **People discovered** → For each person, calls `enrich_people.sh "Name" "event-dir/Name.vcf"` to store vCard adjacent to notes.md
5. **People section built** → Reads .vcf files to populate People section in notes.md with name + email + phone
6. **Workflow end** → Opens notes.md using `${EDITOR:?EDITOR variable unset} /path/to/notes.md` (inline, no helper needed)

All scripts are shell-safe and handle missing inputs gracefully. vCard files are standard RFC 6350 format.
