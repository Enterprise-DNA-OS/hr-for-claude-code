---
description: Record a last day and reason, and create the offboarding checklist.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`; if a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- terminate --employee="..." --last-day=YYYY-MM-DD --reason="..." --evidence="resignation email" --actor="..."`.

Final pay and leave payout happen in payroll. Offer /draft-service-letter.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
