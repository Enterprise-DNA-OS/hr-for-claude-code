# HR for Claude Code: operating instructions

This file is the brain. Claude Code reads it at the start of every session. It says who this is for, how work gets done, and the one right way to do each recurring job.

## Who this is for

- **Business:** [YOUR BUSINESS]
- **Operator:** [YOUR NAME], [your role]
- **What matters most:** [the one or two outcomes you care about]

Fill this in once. A worker with context knows. A worker without it guesses.

## How to work

1. **Take a brief, not a script.** The operator describes the outcome. You run the right command and present the answer.
2. **Read before you write.** Before drafting anything about a record, read its full history first.
3. **Plain language.** Short sentences. No filler. Numbers in tables.
4. **Silent success, loud problems.** No play-by-play. Say what broke and what you did about it.
5. **Stop at the line.** Anything that sends, deletes, or faces a customer waits for a yes in this session.

## Routing table: one right way for each recurring job

| When the operator asks for... | Use this |
|---|---|
| Every command in this HR system, one line each | `/help` |
| The employing companies, their country, headcount and whether an Australian one is a small business employer | `/employers` |
| The staff list, filtered by employer, department, type or status | `/people` |
| One employee's whole file: employment, agreements, statements, leave, reviews, tickets, policies, cases, tasks and any record check that fails | `/person` |
| The reporting lines as a tree, with direct reports per manager | `/org` |
| Headcount and FTE by employer, department and employment type | `/headcount` |
| Leavers in the last twelve months, first-year leavers and the turnover rate per employer | `/turnover` |
| Leave requests waiting for a decision, with how long each has waited | `/leave` |
| Who is on approved leave today or in the next two weeks | `/away` |
| Leave balances from the last payroll import, with annual leave above the threshold flagged | `/balances` |
| Reviews and one-on-ones booked, due soon or overdue | `/reviews` |
| NZ 90-day trial periods and probation periods, when each ends and whether the review is done | `/trials` |
| Licences, tickets and certificates by expiry: expired, expiring, current | `/certifications` |
| Who has not acknowledged a policy at its current version | `/policies` |
| Open employee relations cases: performance, conduct, grievances, wellbeing, with the next step and its due date | `/cases` |
| Open onboarding, offboarding and other people tasks, overdue first | `/tasks` |
| Australian information statements: FWIS, CEIS and FTCIS, when each fell due and when it was last given | `/statements` |
| Work anniversaries in the next 30 days | `/anniversaries` |
| Everything that needs a person: leave waiting, overdue reviews, trials ending, expiring tickets and visas, unacknowledged policies, case steps overdue, onboarding late, large leave balances, leavers | `/attention` |
| Check the employment records against the NZ and Australian rules in docs/compliance.md (written agreements, trial periods, information statements, fixed-term limits, right to work, required tickets) and report each failure with its rule | `/compliance` |
| The last 100 changes: who changed what, when, and on what evidence | `/activity` |
| The Monday people review in one run: attention, record checks, who is away, reviews due and trials ending | `/weekly-review` |
| Add an employing company (NZ or AU) | `/add-employer` |
| Add a new starter and create their onboarding checklist | `/hire` |
| Change an employee's details: title, department, manager, hours, type, dates, visa, trial | `/update` |
| Record an employment agreement, a variation or a fixed-term renewal, with the day it was signed | `/agreement` |
| Record that an Australian employee was given the FWIS, CEIS or FTCIS | `/statement` |
| Record a leave request | `/request-leave` |
| Approve or decline a leave request | `/decide-leave` |
| Book a trial, probation, annual review or one-on-one | `/book-review` |
| Record a review as done, with its outcome. An annual review books the next one a cycle later | `/complete-review` |
| Record a licence, ticket or certificate with its expiry | `/add-cert` |
| Add a policy or issue a new version, so everyone it applies to must acknowledge it again | `/add-policy` |
| Record that someone acknowledged a policy at its current version | `/acknowledge` |
| Open an employee relations case with an owner and the next step | `/open-case` |
| Add a dated note to a case | `/case-note` |
| Set the next step on a case, or close it with an outcome | `/update-case` |
| Add a people task to someone's checklist | `/task` |
| Tick off an onboarding, offboarding or other task | `/done` |
| Record a last day and reason, and create the offboarding checklist | `/terminate` |
| Bring employees across from Employment Hero, or leave balances from payroll | `/import` |
| Everything in the database as JSON, one file per table | `/export` |
| Draft a letter of offer for a new starter from their record | `/draft-offer` |
| Draft one reminder per person for policies to acknowledge, tickets to renew and visas to update | `/draft-reminders` |
| Draft a certificate of service for someone who has left or is leaving | `/draft-service-letter` |
| Employee files, manager packs and the annual leave liability, in your brand | `/docs` |
| Render the read-only HTML pages: this week, record checks and the workforce, in your brand | `/view` |
| Make this system yours in plain language. Add a field, rename stages, change a rule, add a column to a document. Writes the migration, applies it, updates the commands that touch it | `/customise` |
| Add a read-only HTML view (a dashboard page) from a plain-language description, rendered in the operator's brand by `npm run view` | `/new-view` |

If an ask fits nothing here, run the CLI directly (`npm run hr -- help`) and then propose a new command for it.

## Hard rules

- Never send email or messages from here. Draft to `drafts/`, a person sends.
- Never delete records without an explicit yes in this session. Prefer marking closed or archived.
- Never invent a record. If a name is ambiguous, list the candidates and ask.
- The database is the source of truth. If the answer is not in it, say so.

## People rules

- Monday: `/weekly-review`. When a new version of a policy goes out: `/add-policy`, then `/draft-reminders`. Before day 80 of any NZ trial: `/trials` with the manager.
- Personal information stays here. Do not paste names, visa details, health or case notes into anything outside this database without the operator asking for it in this session.
- Payroll is not here. Never state what someone is paid or owed: leave balances are a snapshot from payroll with an as-at date; say it.
- Case notes are facts: what happened, what was said, by whom, when. No opinions, no diagnoses. Performance and conduct process follows the business's policy and legal advice.
- Record checks are not legal advice. Say which rule a finding comes from (docs/compliance.md) and that the business decides.
- A visa or a licence is current only if the record says so. If the expiry is missing, ask for it from VisaView, VEVO or the card itself.

## Where things live

- `scripts/` the CLI. `scripts/lib/db.mjs` picks `DATABASE_URL` (Postgres, Supabase) or the embedded database in `.data/`.
- `supabase/migrations/` the schema, plain SQL. `npm run migrate` applies it.
- `.claude/commands/` the slash commands. Add one every time the same ask comes twice.
- `docs/` the thesis and the guide for moving off Employment Hero.

Built by Enterprise DNA. Installed and run for you as part of Omni: https://enterprisedna.co/omni/instead-of/employment-hero
