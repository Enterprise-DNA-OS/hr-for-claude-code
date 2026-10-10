# Moving off Employment Hero

Employment Hero keeps each person as an employee record inside an organisation, with their job, manager, employment type and dates, plus leave, documents, policies, reviews and certifications around them. The employee record maps straight onto the `employees` table here, and an organisation is an employer.

Keep payroll where it is. If Employment Hero runs your payroll, either keep that part or move payroll to Xero, MYOB or KeyPay first. This system does not pay anyone.

## 1. Download your employees

Employment Hero's help centre, [How do I download or export our current data from our platform](https://help.employmenthero.com/hc/en-au/articles/17427183987983), describes the route that works on every HR plan:

1. Go to **People** > **Import Employees**.
2. Pick the **Advanced Import Employees** template (it holds the most employee details).
3. Tick **Include existing user information**, and **Include terminated users** if you want your leavers' history too.
4. Click **Download**, then save the sheet as CSV.

Premium plans can also build a custom report with exactly the columns you want.

## 2. Set up your employers once

```bash
npm run hr -- add-employer --name="Your Company Ltd" --country=NZ --eh-name="Your Company" --actor="Your name"
```

`--eh-name` is the organisation name as it appears in the export. Add `--accredited=true` for an NZ employer with Immigration NZ accreditation.

## 3. Import, dry run first

```bash
npm run hr -- import employment-hero --file=imports/employees.csv --dry-run --actor="Your name"
npm run hr -- import employment-hero --file=imports/employees.csv --actor="Your name"
```

The import reads these columns, under any of the names shown:

| Field | Column names it accepts |
|---|---|
| Code (required) | Employee Code, Employee ID, Employee Number, Employee No, Payroll ID |
| Name (required) | First Name, Last Name, Known As |
| Start date (required) | Start Date, Employment Start Date, Commencement Date |
| Employment type | Employment Type, Employment Status (full time, part time, casual, fixed term or contract) |
| Job | Job Title, Department or Team, Location, Hours Per Week |
| Manager | Primary Manager, Manager, Primary Manager Email, Reports To (matched by code, email or full name, after every row is in) |
| Dates | Contract End Date (fixed term), Termination Date, Date of Birth (YYYY-MM-DD or DD/MM/YYYY) |
| Employer | Organisation, Company, Business (or pass `--employer=` when the file holds one company) |
| Contact | Work Email, Email, Mobile |

If your sheet names a column differently, or uses an employment type the import does not know, name it in a map file and pass `--map=`:

```json
{
  "columns": { "manager": "Line Manager Email" },
  "employers": { "Your Company": "Your Company Ltd" },
  "types": { "Permanent Full Time": "full_time" }
}
```

Nothing is saved until every row reads cleanly: the import lists the rows it could not read and stops. Running it again is safe. A record that changed in Employment Hero since the last import is listed for you to check, and only saved when you run again with `--update`.

## 4. Bring leave balances from payroll

Export a leave balance report from payroll as CSV with Employee Code, Leave Type, Balance (hours) and As At columns, then:

```bash
npm run hr -- import balances --file=imports/balances.csv --actor="Your name"
```

Annual leave, sick, personal or carer's, long service and alternative holidays are recognised by name. Re-import whenever you want the liability current.

## 5. Bring the rest across

These do not come out in the employee template. Record them with the commands, or ask Claude Code to read a spreadsheet you have and write them in:

- **Agreements:** the signed date and where the signed copy lives (`/agreement`). The NZ trial period check needs the signed date.
- **Australian information statements:** when the FWIS, CEIS and FTCIS were given (`/statement`).
- **Certifications and licences** with expiry dates (`/add-cert`).
- **Policies and acknowledgements** (`/add-policy`, `/acknowledge`).
- **Reviews** booked and their outcomes (`/book-review`, `/complete-review`).
- **Documents** themselves (contracts, ID, certificates) stay in your document store. Download them from Employment Hero before the subscription ends and record where they are.

## What does not carry over

- Payroll history, payslips and pay rates.
- Employment Hero's own forms, workflows and e-signature trail. The signed documents come across as files you keep; the trail behind them does not.
- Rosters and timesheets, if you used them. Those belong in a rostering tool or payroll.

Moving the parts the template does not hold, building a self-service page for staff, and connecting payroll so balances arrive on their own is what Enterprise DNA does in a switch: https://enterprisedna.co/omni/instead-of/employment-hero
