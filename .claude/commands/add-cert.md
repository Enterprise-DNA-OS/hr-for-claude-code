---
description: Record a licence, ticket or certificate with its expiry.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Resolve people by code, full name or email with `people`. If a name is ambiguous, show the candidates and ask. Never invent an actor, a date, a reason, an outcome or evidence. Personal details stay in this database: do not paste them anywhere else.

Run `npm run hr -- add-cert --employee="..." --name="..." --issued=YYYY-MM-DD --expires=YYYY-MM-DD [--required=false] --evidence="copy on file" --actor="..."`.

A renewal is a new record. The old one stays as history.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
