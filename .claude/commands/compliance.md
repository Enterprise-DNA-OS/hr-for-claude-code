---
description: Check the employment records against the NZ and Australian rules in docs/compliance.md (written agreements, trial periods, information statements, fixed-term limits, right to work, required tickets) and report each failure with its rule.
---

Read CLAUDE.md first. Add `--json` when you need to read the result yourself. Never invent an actor, a date, a reason or evidence.

Run `npm run hr -- compliance`.

1. Report as a table: rule, person, finding. Right to work and lapsed tickets first (someone may be working who should not be), then trial periods and agreements, then the Australian statements.
2. For each finding, say the fix the operator can approve: the agreement to record, the statement to give and record, the visa to check in VisaView or VEVO, the ticket to renew. Draft any message to drafts/.
3. Each rule and its source is in `docs/compliance.md`. If a rule there is out of date, say so and stop. Do not guess at law. The operator confirms the rule, then you update the doc and the check together.

These are record checks, not legal advice. Whether a trial period holds or a dismissal is fair is for the business and its lawyer.

Nothing here sends, deletes or publishes. Drafts go to drafts/ for a person to send.
