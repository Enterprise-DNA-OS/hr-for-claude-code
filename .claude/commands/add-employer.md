---
description: Add an employing company (NZ or AU).
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- add-employer --name="..." --country=NZ [--accredited=true] [--eh-name="name in Employment Hero"] --actor="..."`.

Mark an NZ employer accredited if it holds Immigration NZ accreditation for AEWV holders.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
