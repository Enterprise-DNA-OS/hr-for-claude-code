---
description: Set the next step on a case, or close it with an outcome.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- update-case --case="name or id" --next-step="..." --due=YYYY-MM-DD | --close --outcome="..." --actor="..."`.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
