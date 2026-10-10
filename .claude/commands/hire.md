---
description: Add a new starter and create their onboarding checklist.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- hire --employer="..." --code=N15 --first="..." --last="..." --type=full_time --start=YYYY-MM-DD [--title --department --manager --hours --trial=90 --probation-end --fixed-end --work-rights=visa --visa-expires] --actor="..."`.

Ask for anything missing instead of guessing. A visa holder needs the expiry from VisaView (NZ) or VEVO (AU). Offer /draft-offer afterwards.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
