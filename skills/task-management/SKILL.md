---
name: task-management
description: Use when capturing, triaging, marking, or migrating follow-up tasks between markdown notes and Daylite, logging contacts, or running a weekly review.
---

# Task management: markdown capture, Daylite commitments

Blend of GTD (next actions, waiting-for, weekly review), Bullet Journal (state marks, migration as a forced decision), and CRM habits (log every touch, no dead ends). Claude does the clerical work; Michael decides.

## Core rules

1. **Capture anywhere, commit in one place.** Markdown (e.g. `~/repos/events/<event>/followup_*.md`) is the inbox. Daylite is the system of record for anything committed.
2. **One home per item.** Never copy an item into a second file or list. Views are not maintained by hand.
3. **Migrate, then freeze.** When an item is committed to Daylite, mark it `[>]` and append `-> Daylite: <task title>`. From then on its status lives only in Daylite; the markdown line is never edited again.
4. **Clarify on commit.** Daylite task title starts with a verb (next action). Link it to its person(s), company, and project. Add a due date only if one is real. Default priority.
5. **Touch -> note.** Every message sent, call held, or meeting attended becomes a Daylite note linked to the person (and project if relevant).
6. **No dead ends.** After any contact, there is either a next-step task or an explicit decision of none.
7. **WIP limit.** At most 3 items in `[/]` started at once.
8. **Propose, then write.** For bulk or ambiguous changes, list proposed Daylite actions and wait for approval. Single, explicit requests can be done directly.

## Status marks (ASCII, markdown checkbox)

```text
- [ ] todo
- [/] started
- [x] finished
- [-] dropped                      (optional: reason)
- [<] deferred                     (optional: until YYYY-MM-DD)
- [@] delegated @Name              (waiting for)
- [>] migrated -> Daylite: <task title>
```

`[ ] [x] [/] [-] [>] [<]` follow Bullet Journal / Obsidian Tasks conventions. `[@]` is local.

## Weekly review (Claude-run)

1. List open, started, deferred, and delegated items across markdown and Daylite (open tasks, worklist).
2. List people not contacted in N weeks who have an open loop.
3. For each item, Michael answers: do / keep / defer / delegate / drop. Claude applies the marks and Daylite changes.
4. An event is closed when its markdown holds only marks and pointers.

## Daylite tool quirks

- **Notes are title-only.** No body field is writable or readable. Keep note titles short; put long text in a task's `details`, or give Michael text to paste.
- **link-daylite-records** only links pairs involving a task, note, or appointment. Use **create-role** for person-company, person-project, company-project.
- **create-role person-company** may set the company as the person's default. Warn when that happens.
- **URL labels** must match existing labels (seen: Website, Other, LinkedIn, Articles/Events, YouTube, Podcast); an unknown label gets a random one. Set the label explicitly and check the result.
- **No deletes.** Daylite tools cannot delete records; ask Michael to delete in the app.
- Disambiguate people by context (project, event, recent links) before writing; ask when two candidates remain.

## Files in event repos

Repo or event `CLAUDE.md` files may add local conventions (session tags like `(HH:MM Color)`, file names). They extend these rules; the one-home and migrate-then-freeze rules still apply.
