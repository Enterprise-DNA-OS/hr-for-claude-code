<h1 align="center">HR for Claude Code</h1>

<p align="center">
  <strong>The open-source HR system that is just a database and Claude Code.</strong>
</p>

<p align="center">
  Created by <a href="https://www.enterprisedna.co"><strong>Enterprise DNA</strong></a>. Free and open source. Works with Claude Code, Codex, OpenCode or Cursor.
</p>

<!-- three-doors -->
<table align="center">
  <tr>
    <td align="center"><strong>Do it yourself</strong><br/>Clone it, run it, own it. Free, MIT.<br/><a href="#quick-start">Quick start</a></td>
    <td align="center"><strong>We customise it</strong><br/>Your fields, your rules, your Employment Hero data brought across.<br/><a href="https://enterprisedna.co/omni/book/?utm_source=github&utm_medium=readme&utm_campaign=employment-hero">Book a call</a></td>
    <td align="center"><strong>We run it for you</strong><br/>Installed, connected and operated inside Omni. Setup fee, then a retainer.<br/><a href="https://enterprisedna.co/omni/instead-of/employment-hero?utm_source=github&utm_medium=readme&utm_campaign=employment-hero">How it works</a></td>
  </tr>
</table>

<p align="center">
  <a href="#what-is-this">What is this</a> &bull;
  <a href="#why-no-front-end">Why no front end</a> &bull;
  <a href="#quick-start">Quick start</a> &bull;
  <a href="#the-commands">Commands</a> &bull;
  <a href="#instead-of-employment-hero">Instead of Employment Hero</a> &bull;
  <a href="#want-it-installed-and-run-for-you">Installed for you</a> &bull;
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Node-20+-339933?style=flat-square" alt="Node 20+" />
  <img src="https://img.shields.io/badge/PostgreSQL-any-336791?style=flat-square" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/PGlite-embedded-3ecf8e?style=flat-square" alt="PGlite" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="MIT License" />
</p>

---

## What is this

HR for Claude Code does the job you pay Employment Hero for, as a Postgres database and a set of agent commands. There is no web front end. You open the folder in [Claude Code](https://claude.com/claude-code) (or Codex, OpenCode, Cursor: see `AGENTS.md`) and ask for what you want in plain language. It runs the right query, and it can answer questions the Employment Hero dashboard cannot.

Employment Hero's [Australian pricing page](https://employmenthero.com/au/pricing/) lists HR Essentials at $10 and HR Engage at $14 per user, with a minimum of 10 users, and add-ons such as HR Advisory at $14 and LMS Plus at $17 per employee a month (checked 10 October 2026). HR Elite and Employment Unlimited, the only tier with payroll, are quoted. The bill counts every employee, every month, and grows with every add-on.

Want the same thing with a web front end, or built on a different stack? That is a customisation, and it is exactly what Enterprise DNA does: [book a call](https://enterprisedna.co/omni/book/?utm_source=github&utm_medium=readme&utm_campaign=employment-hero).

It is for the owner, general manager or people and payroll advisor of a New Zealand or Australian business with 20 to 300 staff, often with an NZ company and an Australian one. It holds employees and reporting lines, employment agreements and their signed dates, Australian information statements, leave requests and balances from payroll, reviews and trial periods, licences and tickets, policies and who has acknowledged them, employee relations cases, and onboarding and offboarding checklists. On top sit the jobs HR does every week: decide leave, chase reviews, close out trials before day 90, keep tickets and visas current, and check the records against NZ and Australian employment law. Payroll stays in your payroll system.

### Ten questions this answers today

1. Who is on a 90-day trial that ends in the next fortnight with no review done? `/trials`
2. Which trial periods will not hold because the agreement was signed after the person started? `/compliance`
3. Which casuals are due the Casual Employment Information Statement again? `/statements`
4. Whose visa expires in the next 60 days, and is anyone working on one that has expired? `/attention`
5. Who is driving a forklift on a ticket that has lapsed? `/certifications`
6. Which leave requests has nobody answered, and which manager owes the answer? `/leave`
7. Who has not had an annual review in the last twelve months, and none is booked? `/attention`
8. Who has not acknowledged the new Health and Safety Policy? `/policies`
9. Who is carrying more than eight weeks of annual leave? `/balances`
10. Which Australian fixed-term contracts run past the two-year limit? `/compliance`

These are working commands on the demo data, not claims about what Employment Hero can or cannot report.

## Why no front end

- The front end was only ever there because the database was hard to talk to. That is no longer true.
- Your data sits in plain Postgres tables you own. Any tool can read them. No export, no lock-in.
- No seats, no tiers, no add-ons. Read [docs/why-no-front-end.md](docs/why-no-front-end.md) for the honest trade-offs too, starting with staff self-service.

## Quick start

Sixty seconds, no database install (an embedded Postgres runs inside Node):

```bash
git clone https://github.com/Enterprise-DNA-OS/hr-for-claude-code.git
cd hr-for-claude-code
npm install
npm run demo
```

Then open the folder in Claude Code and type `/weekly-review`: what needs a person, the record checks, who is away, and the reviews and trials due. Or ask in plain words: "is anyone working on an expired visa?"

The demo is Totara Foods, a fictional NZ food manufacturer (an accredited employer) with a small Australian sales and distribution company: 17 people on the books, one who left this year and one leaving next week. It is deliberately untidy: a forklift operator whose ticket lapsed ten days ago, a driver whose visa expired, a supervisor whose visa and first aid certificate both expire soon, a trial period signed two days after the start date, a trial period in an AEWV holder's agreement, a sales coordinator with no signed agreement and an open performance case, a casual overdue for the 12-month CEIS, a 30-month fixed-term contract with no FTCIS, a new starter with no FWIS, a leave request nobody has answered, an overdue review, a trial ending in nine days with no review, and nine weeks of annual leave on one person. Dates move with today.

`npm test` runs every command against a temporary database and must print PASS. `npm run view` writes the read-only pages to `views/`; `npm run docs` writes employee files, manager packs and the annual leave liability to `docs-out/`.

### Use it with your own Postgres or Supabase

Copy `.env.example` to `.env`, set `DATABASE_URL`, then `npm run migrate`. Same commands, shared data, no per-user fee. People records are personal information: put the database somewhere with access control and backups, and keep `.data/` out of shared folders.

## The commands

Every command runs `npm run hr -- <command>`, takes `--json`, and matches people by code, full name, email, part of a name or the start of an id. An ambiguous name lists the candidates and stops. Every change needs `--actor` and lands in the activity log with what it was before. There is no delete command.

| Command | What it does |
|---|---|
| `/help` | Every command in this HR system, one line each. |
| `/employers` | The employing companies, their country, headcount and whether an Australian one is a small business employer. |
| `/people` | The staff list, filtered by employer, department, type or status. |
| `/person` | One employee's whole file: employment, agreements, statements, leave, reviews, tickets, policies, cases, tasks and any record check that fails. |
| `/org` | The reporting lines as a tree, with direct reports per manager. |
| `/headcount` | Headcount and FTE by employer, department and employment type. |
| `/turnover` | Leavers in the last twelve months, first-year leavers and the turnover rate per employer. |
| `/leave` | Leave requests waiting for a decision, with how long each has waited. |
| `/away` | Who is on approved leave today or in the next two weeks. |
| `/balances` | Leave balances from the last payroll import, with annual leave above the threshold flagged. |
| `/reviews` | Reviews and one-on-ones booked, due soon or overdue. |
| `/trials` | NZ 90-day trial periods and probation periods, when each ends and whether the review is done. |
| `/certifications` | Licences, tickets and certificates by expiry: expired, expiring, current. |
| `/policies` | Who has not acknowledged a policy at its current version. |
| `/cases` | Open employee relations cases: performance, conduct, grievances, wellbeing, with the next step and its due date. |
| `/tasks` | Open onboarding, offboarding and other people tasks, overdue first. |
| `/statements` | Australian information statements: FWIS, CEIS and FTCIS, when each fell due and when it was last given. |
| `/anniversaries` | Work anniversaries in the next 30 days. |
| `/attention` | Everything that needs a person: leave waiting, overdue reviews, trials ending, expiring tickets and visas, unacknowledged policies, case steps overdue, onboarding late, large leave balances, leavers. |
| `/compliance` | Check the employment records against the NZ and Australian rules in docs/compliance.md (written agreements, trial periods, information statements, fixed-term limits, right to work, required tickets) and report each failure with its rule. |
| `/activity` | The last 100 changes: who changed what, when, and on what evidence. |
| `/weekly-review` | The Monday people review in one run: attention, record checks, who is away, reviews due and trials ending. |
| `/add-employer` | Add an employing company (NZ or AU). |
| `/hire` | Add a new starter and create their onboarding checklist. |
| `/update` | Change an employee's details: title, department, manager, hours, type, dates, visa, trial. |
| `/agreement` | Record an employment agreement, a variation or a fixed-term renewal, with the day it was signed. |
| `/statement` | Record that an Australian employee was given the FWIS, CEIS or FTCIS. |
| `/request-leave` | Record a leave request. |
| `/decide-leave` | Approve or decline a leave request. |
| `/book-review` | Book a trial, probation, annual review or one-on-one. |
| `/complete-review` | Record a review as done, with its outcome. An annual review books the next one a cycle later. |
| `/add-cert` | Record a licence, ticket or certificate with its expiry. |
| `/add-policy` | Add a policy or issue a new version, so everyone it applies to must acknowledge it again. |
| `/acknowledge` | Record that someone acknowledged a policy at its current version. |
| `/open-case` | Open an employee relations case with an owner and the next step. |
| `/case-note` | Add a dated note to a case. |
| `/update-case` | Set the next step on a case, or close it with an outcome. |
| `/task` | Add a people task to someone's checklist. |
| `/done` | Tick off an onboarding, offboarding or other task. |
| `/terminate` | Record a last day and reason, and create the offboarding checklist. |
| `/import` | Bring employees across from Employment Hero, or leave balances from payroll. |
| `/export` | Everything in the database as JSON, one file per table. |
| `/draft-offer` | Draft a letter of offer for a new starter from their record. |
| `/draft-reminders` | Draft one reminder per person for policies to acknowledge, tickets to renew and visas to update. |
| `/draft-service-letter` | Draft a certificate of service for someone who has left or is leaving. |
| `/docs` | Employee files, manager packs and the annual leave liability, in your brand. |
| `/view` | Render the read-only HTML pages: this week, record checks and the workforce, in your brand. |
| `/customise` | Make this system yours in plain language. Add a field, rename stages, change a rule, add a column to a document. Writes the migration, applies it, updates the commands that touch it. |
| `/new-view` | Add a read-only HTML view (a dashboard page) from a plain-language description, rendered in the operator's brand by `npm run view`. |

### Your first hour: ten things to ask for

1. "Put our company name and logo on the employee files." (brand.json)
2. "Do a test import of our Employment Hero employee export, without saving it."
3. "Load the leave balances from this payroll report."
4. "Which of our NZ staff have no signed agreement on file?"
5. "Record that Emily was given the Fair Work Information Statement by email today."
6. "Who has a trial period ending this month, and who is their manager?"
7. "Add our forklift and first aid tickets with their expiry dates from this spreadsheet."
8. "We issued version 4 of the Code of Conduct today. Draft the reminders."
9. "Add a uniform size and a T-shirt order to onboarding." (/customise)
10. "Write the manager pack for Ben and save it."

## Instead of Employment Hero

Employment Hero's People > Import Employees > Advanced Import Employees, with existing (and terminated) users ticked, downloads a template filled with every employee's details. Save it as CSV and bring it across:

```bash
npm run hr -- add-employer --name="Your Company Ltd" --country=NZ --eh-name="Your Company" --actor="Your name"
npm run hr -- import employment-hero --file=imports/employees.csv --dry-run --actor="Your name"
npm run hr -- import employment-hero --file=imports/employees.csv --actor="Your name"
npm run hr -- import balances --file=imports/balances.csv --actor="Your name"
```

The import accepts the common column names for each field, matches managers after every row is in, and saves nothing until every row reads cleanly. Running the same file twice changes nothing; a changed record needs `--update`. Agreements, statements, tickets, policies and reviews are recorded with their commands or read in from your own spreadsheets: [what maps and what does not](docs/replace-employment-hero.md).

## Compliance, documents and views

`/compliance` checks the records against the rules an NZ or Australian employer works under: a signed written agreement (Employment Relations Act 2000 ss63A, 64, 65), 90-day trial periods agreed in writing before day one (s67A), no trial period for AEWV holders at an accredited employer, the FWIS, CEIS and FTCIS (Fair Work Act ss125, 125A, 125B, with the CEIS schedule for small and other employers), the two-year limit on Australian fixed-term contracts (s333E), right to work (Immigration Act 2009 s350, Migration Act 1958 s245AB), and lapsed tickets for work that needs one. Each rule and its source: [docs/compliance.md](docs/compliance.md). It is a record check, not legal advice.

Verification: CI runs `npm test` on Node 20 and 22 on Linux and Windows, plus a job against PostgreSQL 17. `TEST_DATABASE_URL` must name an empty, disposable database. [Why this target was chosen](docs/research.md).

## Architecture

```
hr-for-claude-code/
  CLAUDE.md                 how the operator wants this run (routing table + house rules)
  AGENTS.md                 the same, for Codex / OpenCode / Cursor / Gemini CLI
  .claude/commands/         the slash commands
  scripts/                  the CLI the commands drive
  scripts/lib/db.mjs        one adapter: DATABASE_URL (pg) or embedded PGlite
  supabase/migrations/      plain SQL schema
  supabase/seed.sql         demo data
  docs/                     the thesis and the migration guide
```

## Built for coding agents

The database, CLI and command recipes work with Claude Code, Codex, OpenCode or Cursor. Ask your coding agent for a new command and have it implement and test the change against the same records.

## Contributing

Issues and pull requests are welcome. Keep the shape: plain SQL, a small CLI, a slash command per recurring job, no front end.

## Want it installed and run for you?

Enterprise DNA installs HR for Claude Code for your business, migrates your Employment Hero data, connects it to the rest of your tools, and runs it for you as part of **Omni**, our managed Command Center. One setup fee, then a monthly retainer.

- Book a call: [enterprisedna.co/omni/book](https://enterprisedna.co/omni/book/?offer=replace-software&utm_source=github&utm_medium=readme&utm_campaign=employment-hero)
- Read more: [enterprisedna.co/omni/instead-of/employment-hero](https://enterprisedna.co/omni/instead-of/employment-hero?utm_source=github&utm_medium=readme&utm_campaign=employment-hero)

## License

MIT. Copyright (c) 2026 Enterprise DNA.
