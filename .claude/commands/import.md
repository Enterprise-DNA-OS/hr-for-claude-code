---
description: Bring employees across from Employment Hero, or leave balances from payroll.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- import employment-hero --file="imports/employees.csv" [--employer="..."] [--map="imports/map.json"] --dry-run --actor="..."`.

Always run with --dry-run first and show the counts. Leave balances: import balances --file=... (Employee Code, Leave Type, Balance, As At). Changed records need --update after the operator has reviewed them. See docs/replace-employment-hero.md.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
