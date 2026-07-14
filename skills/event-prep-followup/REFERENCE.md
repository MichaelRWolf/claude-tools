# Event Prep & Follow-up -- Detailed Reference

## Event Discovery Process

### Step 1: Parse the Prompt

Look for event identifiers:

- **Date patterns:** "July 7", "June 25", "2026-07-07", "next Tuesday"
- **Event names:** "Trends in Education", "GenAI Day", "Software Crafters"
- **Person names:** "with Alan", "Kristen and Marie", "Woody + James"
- **URLs:** Eventbrite, Zoom registration, calendar links
- **Keywords:** "event", "meeting", "dinner", "workshop", "roundtable", "hangout"

Examples:

```text
"prep for July 7 event" → date: 2026-07-07
"prep June 25 dinner with Kristen" → date: 2026-06-25, person: Kristen
"prep https://www.eventbrite.com/e/123456" → extract event from URL
```

### Step 2: Search Events/ Directory

Scan `/Users/michael/repos/Events/` for matching directories:

- **By date:** Directory starts with `YYYY-MM-DD` matching the date
- **By name:** Directory contains the event name (case-insensitive)
- **By person:** Directory contains a person's name

If multiple matches, show the user and ask which one.

Example:

```text
Found:
1. 2026-07-07_GenAI_Day_7/
2. 2026-07-07_Team_Standup/

Which one?
```

### Step 3: Search Calendar.app

If not found in Events/, query Calendar.app for events on the date:

- Search by date
- Search by event name (if provided)
- Show results (event name, date, time, description, location)

If found, capture:

- Event title
- Date and time
- Description (if any)
- Attendees (if any)
- Location or Zoom link

### Step 4: Handle Missing Calendar Entry

If event is real but not in Calendar.app yet:

- Ask: "Should I create a calendar entry for this? I can generate a .ics file and open it in Calendar."
- If yes:
  - Create a basic .ics file with the event details
  - Open it with `open event.ics` (Calendar.app handles it)
  - User confirms in Calendar.app, comes back to complete prep

### Step 5: Ask for Details (Last Resort)

If not found anywhere:

- Prompt: "Tell me about this event. What's the date? Who's organizing? Any links?"
- Collect: date, name, people, links, purpose, format
- Suggest directory name based on what user provided

## Phase Lifecycle

### Prep Phase

- **Status:** ✓ (ready) or ⊘ (pending)
- **What happens:** Collect calendar info, event page, links, people, prep materials
- **When complete:** Directory created, notes.md exists, follow-up items drafted
- **How to mark done:** `Prep: ✓`

### Attend Phase

- **Status:** ⊘ (in progress) or ✓ (done)
- **What happens:** During event, capture notes, update notes.md
- **When complete:** notes.md has Context, Links, People, synthesis, and Follow-up sections filled in
- **How to mark done:** `Attend: ✓` (notes.md complete)

### Follow-up Phase

- **Status:** Todo list with per-item status (ready / WIP / done)
- **What happens:** Execute follow-up actions (messages, research, writing, activities)
- **When complete:** All items marked done
- **How to mark done:** Check off items as complete

### Closed Phase

- **Status:** ✓ (all done) or - (not started)
- **When to mark:** After all follow-up items done, no further action expected
- **What it means:** Event is archived; reference materials stored for cross-linking

## Todo Status Conventions

### Follow-up Todo List Format

```markdown
## Follow-up

### Next actions

- [ ] Send thank-yous (ready)
- [ ] Capture key takeaways (WIP)
- [ ] Schedule promised follow-ups (ready)
- [ ] Research queue (WIP)
```

**Status meanings:**

- **ready** -- Next action defined, you can do it now
- **WIP** -- In progress, not finished yet
- **done** (checked) -- Complete, no further work

### Suggested Tags (Converge Over Time)

As you run more events through this workflow, you can label follow-ups:

- **#comms** -- thank-yous, connection messages, LinkedIn reach-outs, announcements
- **#write** -- articles, essays, blog posts, longer-form synthesis
- **#activity** -- experiments, small tries, implementation, things to do
- **#research** -- tools to try, articles/books to read, concepts to explore
- **#decision** -- pivots, commitments, next chapters
- **#blocker** -- something preventing progress, needs input or decision

Example:

```markdown
- [ ] Send thank-yous to Kristen and Marie #comms (ready)
- [ ] Write up Engelbart synthesis #write (WIP)
- [ ] Try Fortune's H-LAM/T framework in our practice #activity (ready)
- [ ] Read Fortune's Substack essays #research (ready)
```

Over time, you'll see patterns in which tags appear most, and can settle on your standard set.

## Outline Assembly Examples

### Minimal Event (Hangout)

```markdown
# Event Title

## Context
- Event:
- Date:
- Why I attended:

## People
- Name -- relationship/context

## My synthesis
- Key insights:
- What changed:

## Follow-up
- [ ] Next action
```

### Conference with Sessions

```markdown
# Event Title

## Context
- Event:
- Date:
- Format:
- Why I attended:

## Links
- Registration:
- Agenda:
- Recordings:

## People
- Attendee -- org/role
- Speaker -- topic

## Sessions
### Session 1 -- Title -- Speaker
- Key ideas:
- Quotes:
- Things to try:

## My synthesis
- Themes:
- What changed:
- What to share:

## References
- Articles mentioned:
- People to follow up with:

## Follow-up
- [ ] Thank speakers
- [ ] Research queue
```

### Organized Workshop/Roundtable

```markdown
# Event Title

## Context
- Event:
- Date/Time:
- Format:
- Purpose:
- Participants:

## Links
- Zoom:
- Agenda:
- Slides:
- Miro:

## People
- Name -- role/company

## Event Design (if you organized it)
- Why meet (bonding, learning, deciding, doing, honoring)
- Success metrics
- Key questions
- Liberating Structures used

## My synthesis
- Themes:
- Pivots/decisions:
- What I want to share:

## Follow-up
- [ ] Send thank-yous
- [ ] Capture key takeaways
- [ ] Any promised follow-ups

## References
- Articles:
- People:
```

**Pattern:** Start with Context, Links, People. Add Sessions/Event Design only if relevant. Always end with My synthesis and Follow-up.

## Directory Naming Convention

### Pattern

`YYYY-MM-DD_event_slug[_person]`

### Examples

- `2026-07-07_GenAI_Day_7/`
- `2026-06-25_Dinner_Kristen_Marie/`
- `2026-05-14_Software_Crafters_Unconference/`
- `2026-06-03_New_GoF/` (New Gang of Four)
- `2026-06-17_Marie_Hangout/`

**Rules:**

- Always start with date in `YYYY-MM-DD` format (today: 2026-07-01)
- Use underscore separators
- Slugify the event name (no spaces, capitalize words)
- If event organized with/by a person, add their name(s) at the end
- Keep slug concise but recognizable

## Symmetry: Prep ↔ Followup

Both commands use the same event discovery logic:

```text
/event-prep-followup prep for July 7 event
→ Discover event → Create directory → Suggest outline → Write notes.md

/event-prep-followup followup for July 7 event
→ Find event → Show phase status → Manage todos → Update files
```

If event doesn't exist when you ask to "followup", it searches anyway and asks "Did you mean one of these?" before giving up.

## Cross-referencing (Phase 2)

Deferred: Later, this skill could support tagging events by topic (people, projects, themes) and building an index to link across events. For now, rely on directory names and grep.

## Editor Integration: Opening notes.md

At the end of any prep or followup workflow:

1. Check `$EDITOR` environment variable
2. If set: `$EDITOR /path/to/notes.md`
3. If not set: Warn user and do NOT default to vi or ed
   - Message: "Warning: $EDITOR not set. To edit notes.md, set EDITOR env var or open the file manually."
4. Do not block workflow completion on this failure
5. User can manually open notes.md later if needed

## ICS File Handling

If a `.ics` file is provided as input during prep:

1. Identify the .ics file in the skill invocation
2. Save it in the event directory as a sibling to notes.md
   - Example: `/Users/michael/repos/Events/2026-07-07_GenAI_Day/GenAI_Day.ics`
3. Open it with `open(1)`:
   - `open /path/to/event.ics`
   - macOS Calendar.app handles the .ics import
   - User sees Calendar app import dialog
4. After import, return to skill workflow to continue with notes.md creation

**Use case:** User exports event from Eventbrite, passes .ics to skill, event auto-creates in Calendar.

## People Enrichment via vCard

When inferring or discovering people for an event:

### Sources

- Event page (attendees list, speaker bios)
- Explicitly named in prep input ("with Kristen and Marie")
- Added to People section during outline customization
- Extracted from Calendar.app event attendees

### Workflow: Query → Store → Augment

1. **Query Contacts.app** via `enrich_people.sh "Name"` (5-second timeout, non-blocking)
2. **Store as vCard** adjacent to notes.md: `2026-07-07_Event_Name/Kristen_Walsh.vcf`
3. **Read vCards** to populate People section in notes.md

### vCard Storage

Each person discovered gets a separate RFC 6350 vCard file in the event directory:

```text
/Users/michael/repos/Events/2026-07-07_GenAI_Day/
├── notes.md
├── Kristen_Walsh.vcf
├── Marie_Chen.vcf
└── Alan_Turing.vcf
```

### vCard Format (RFC 6350)

Minimal vCard with only non-empty fields:

```vcard
BEGIN:VCARD
VERSION:4.0
FN:Jess Wolfe
EMAIL:jess@swarmia.com
TEL:+1-555-5678
URL:https://www.linkedin.com/in/thejessicawolfe/
END:VCARD
```

- `FN` -- Full name (always present)
- `EMAIL` -- Extracted from Contacts; omitted if not found/unavailable
- `TEL` -- Extracted from Contacts; omitted if not found/unavailable
- `URL` -- Extracted from Contacts (LinkedIn, websites, etc.); omitted if not found/unavailable

### Augmenting notes.md People Section

From vCards, populate the People section. Format: each person as a bullet, contact info inline:

```markdown
## People

- Kristen Walsh -- kristen.walsh@acme.com -- +1-502-555-0199
- Marie Chen -- marie@example.com -- +1-555-5678
- Alan Turing
```

(Blanks omitted; LinkedIn added manually if available during editing.)

### Contacts.app Timeout Handling

`enrich_people.sh` with 5-second timeout:

1. Queries Contacts.app
2. If timeout or not found: creates minimal vCard with just name
3. Does not block workflow
4. User can manually augment vCard files later if needed

## End-of-Workflow: Open Editor

After notes.md is written (whether from prep or followup):

```bash
${EDITOR:?EDITOR variable unset} /path/to/notes.md
```

The `${EDITOR:?message}` expansion:

- Uses `$EDITOR` if set, opens the file
- Exits immediately with error if `$EDITOR` is not set (no defaults to vi/ed)
- Simple, direct, fails fast
