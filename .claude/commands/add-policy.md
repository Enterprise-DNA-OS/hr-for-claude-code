---
description: Add a policy or issue a new version, so everyone it applies to must acknowledge it again.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- add-policy --name="..." --version=2 [--effective=YYYY-MM-DD] [--applies-to=NZ] [--link="..."] --actor="..."`.

Then offer /draft-reminders.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
