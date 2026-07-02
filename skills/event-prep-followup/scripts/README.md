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

## Integration

The skill calls these scripts when:

1. **prep for [date/event]** → Searches Events dir and Calendar.app
2. **Missing calendar entry?** → Offers to create .ics file via `create_ics.sh`
3. **followup for [event]** → Searches Events dir for existing event

All scripts are shell-safe and handle missing inputs gracefully.
