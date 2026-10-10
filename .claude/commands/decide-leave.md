---
description: Approve or decline a leave request.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- decide-leave --request="name or id" --decision=approved --by="manager" [--note="..."] --actor="..."`.

Tell the operator to let payroll know about approved leave if payroll is a separate system.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
