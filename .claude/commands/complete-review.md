---
description: Record a review as done, with its outcome. An annual review books the next one a cycle later.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- complete-review --review="name or id" --outcome="..." [--notes="..."] --actor="..."`.

Ask for the outcome in the reviewer's words. Never write one.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
