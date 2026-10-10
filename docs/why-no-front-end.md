# Why there is no front end

Employment Hero is a database of people with a subscription on top. The records underneath are ordinary: employees, agreements, leave, reviews, certificates, policies and cases, plus a few jobs repeated every week. What you pay for, per user per month, is the layer that lets people who do not write SQL get at those records.

That layer used to be the product, because talking to a database was hard. It is not hard any more. Open this folder in Claude Code, ask "who is on a trial period that ends this month and has not been reviewed?", and it runs the query and explains the answer.

## What you gain

- **Answers the dashboard never had.** Which casuals are due the CEIS again, whose visa expires before their next review, which managers owe the most overdue reviews. Ask in your own words.
- **No per-user bill.** The subscription counts every employee. Here, every person in the business is just a row.
- **Your people records in your Postgres.** Plain tables you can back up, query from anything and keep when you leave. HR records outlive any vendor: NZ and Australia both expect them kept for years after someone leaves.
- **Checks that match your rules.** Trial periods, information statements, fixed-term limits and tickets are checked against the rules with sources, and you change a threshold in one row.

## What you give up, honestly

- **Staff self-service.** Employees cannot open an app to request leave, read a policy or update their address. In this version the operator records requests (or imports them) and drafts reminders to staff. A self-service page on the same database is the most common thing Enterprise DNA builds into a business's version.
- **Payroll.** This system does not pay anyone. Pay runs, tax, KiwiSaver, super, Payday Filing and STP stay in your payroll system. Balances come across from payroll as a snapshot.
- **E-signatures and onboarding forms.** Agreements are signed in whatever tool you use; this records the signed date and where the copy lives.
- **A phone app and a vendor help desk.** It runs where Claude Code runs. Enterprise DNA supports the installed version for businesses that want someone to call.

## Who this fits

An owner, general manager or people and payroll advisor who runs HR for 20 to 300 staff and wants the checks and the answers more than the screens. If your staff live in a self-service app every day, keep it, or have Enterprise DNA build the self-service page on top of this.

Installed and run for you: https://enterprisedna.co/omni/instead-of/employment-hero
