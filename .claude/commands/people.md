---
description: The staff list, filtered by employer, department, type or status.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- people [--employer="..."] [--department="..."] [--type=casual] [--status=all]`.

Default is everyone current or starting. --status=left shows former staff.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
