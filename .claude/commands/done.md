---
description: Tick off an onboarding, offboarding or other task.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- done --task="..." [--employee="..."] --evidence="..." --actor="..."`.

If more than one task matches, add --employee or use the id.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
