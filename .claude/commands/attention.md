---
description: Everything that needs a person: leave waiting, overdue reviews, trials ending, expiring tickets and visas, unacknowledged policies, case steps overdue, onboarding late, large leave balances, leavers.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- attention`.

Order the answer by what carries legal or safety risk first: visas, tickets, trials, then the rest.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
