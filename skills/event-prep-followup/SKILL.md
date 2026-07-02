---
name: event-prep-followup
description: Prepare for and follow up from events with structured notes and checklists. Discovers events by date/name/person from prompt, Events directory, or Calendar.app. Creates event directories and notes.md with custom sections. Tracks follow-up status by phase (prep, attend, follow-up, closed) with todo lists marked ready/WIP/done. Use when user says "prep for [date/event]", "followup for [date/event]", or provides an event URL/reference.
---

# Event Prep & Follow-up

Structured workflow for preparing before events and managing follow-ups after. Works with your existing Events/ directory structure.

## Quick Start

### Prep an event

```bash
/event-prep-followup prep for July 7 event
/event-prep-followup prep June 25 dinner with Kristen
/event-prep-followup prep https://www.eventbrite.com/e/123456
```

### Track follow-ups

```bash
/event-prep-followup followup for July 7 event
/event-prep-followup followup June 25
```

## Workflow: Prep for Event

### 1. Discover the Event

When you provide a reference (date, name, person, or URL), I'll search in order:

- **Prompt** -- extract date, name, or person from what you said
- **Events/** -- look for matching directories (by date, event name, person)
- **Calendar.app** -- search by date or event name
- **Ask you** -- if nothing found, describe it and I'll help you set it up

If the event isn't in Calendar.app yet, I'll offer to create a .ics file and open it.

### 2. Create Directory

Once we know the event, I'll:

- Suggest a directory name: `YYYY-MM-DD_event_slug` or `YYYY-MM-DD_event_slug_person`
- Create `/Users/michael/repos/Events/[directory]/`
- Show you what I found (date, name, people, links if any)

### 3. Suggest Outline

I'll assemble a suggested outline based on the event details:

- **Suggested sections:** Context, Links, People, My synthesis, Follow-up
- **Add/drop sections?** -- You customize before I write

### 4. Approve & Write

You review the suggested outline structure, make changes, and I write `notes.md`.

## Workflow: Follow-up for Event

### 1. Find the Event

Search Events/ for a matching directory. Show you what I found.

### 2. Show Phase Status

Display current state by phase:

- **Prep:** ✓ (done) or ⊘ (pending)
- **Attend:** ✓ (done) or ⊘ (pending) -- links to notes.md
- **Follow-up:** Todo list with status (ready / WIP / done)
- **Closed:** ✓ or -

Example:

```text
2026-07-07_Event_Name

Prep:
  ✓ [x] collect links
  ✓ [x] identify people
  
Attend:
  ⊘ notes pending -- notes.md

Follow-up:
  - [ ] send thank-yous (ready)
  - [ ] capture takeaways (ready)
  - [ ] research queue (WIP)
  
Closed: -
```

### 3. Manage Status

You can:

- Update phase (move from Prep → Attend → Follow-up → Closed)
- Mark todos as ready, WIP, or done
- Edit follow-up items directly in the skill interaction

## Advanced: Custom Sections

By default, prep suggests: Context, Links, People, My synthesis, Follow-up.

You can:

- **Drop** a section (don't need People for a solo hangout)
- **Add** a section (Sessions, Event Design, Success Metrics, References)
- **Rename** sections to match your pattern (e.g., "My Takeaways" instead of "My synthesis")

## Custom Outline Example

Event: Software Crafters Unconference

**Default outline:**

```markdown
# Event Title
## Context
## Links
## People
## My synthesis
## Follow-up
```

**Your customization:**

```markdown
# Event Title
## Context
## Links
## People
## Sessions
## My synthesis
## Follow-up
## References
```

I'll suggest the outline, you edit it, I write it.

## Notes on Symmetry

`prep for July 7 event` and `followup for July 7 event` use the same event-finding logic. Same search order, same handling of missing calendar entries.

## Integration with Events/

All event directories follow the pattern:

- Directory: `/Users/michael/repos/Events/YYYY-MM-DD_slug/`
- Main file: `notes.md` (unified or referenced in follow-up sections)
- Optionally: `people.md`, `followup.md`, or other domain files (deferred to later phases)

This skill works with your existing structure and guides you toward consistency without forcing it.
