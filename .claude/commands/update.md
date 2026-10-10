---
description: Change an employee's details: title, department, manager, hours, type, dates, visa, trial.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- update --employee="..." --title="..." --evidence="why" --actor="..."`.

Every change needs --evidence. Use null to clear a field.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
