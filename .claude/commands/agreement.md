---
description: Record an employment agreement, a variation or a fixed-term renewal, with the day it was signed.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- agreement --employee="..." [--kind=variation] --signed=YYYY-MM-DD --evidence="where the signed copy is" --actor="..."`.

The signed date matters: an NZ trial period needs a signature before the start date.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
