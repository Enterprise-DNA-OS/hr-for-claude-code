---
description: Draft one reminder per person for policies to acknowledge, tickets to renew and visas to update.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- draft-reminders`.

Show the operator the list before anything is sent.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
