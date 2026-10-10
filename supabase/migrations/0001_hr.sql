-- HR for Claude Code: the people records an NZ or Australian employer keeps, and the checks on them.
-- Payroll is deliberately out: pay runs, tax and leave accrual stay in the payroll system. Leave
-- balances arrive from payroll as a snapshot (import balances) so the leave liability can be read here.
-- Plain Postgres: runs on any Postgres 14+ and on PGlite. No extensions.

CREATE FUNCTION touch_updated() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at=now(); RETURN NEW; END $$;

CREATE TABLE employers (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 name text NOT NULL UNIQUE CHECK(length(trim(name))>0),
 country text NOT NULL CHECK(country IN ('NZ','AU')),
 accredited_employer boolean NOT NULL DEFAULT false,   -- NZ: holds Immigration NZ accreditation (AEWV)
 eh_name text,                                          -- the organisation name in Employment Hero, for imports
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE employees (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employer_id uuid NOT NULL REFERENCES employers(id),
 code text NOT NULL UNIQUE CHECK(length(trim(code))>0),
 first_name text NOT NULL CHECK(length(trim(first_name))>0),
 last_name text NOT NULL CHECK(length(trim(last_name))>0),
 preferred_name text, email text, phone text,
 job_title text, department text, location text,
 manager_id uuid REFERENCES employees(id),
 employment_type text NOT NULL CHECK(employment_type IN ('full_time','part_time','casual','fixed_term')),
 hours_per_week numeric CHECK(hours_per_week IS NULL OR (hours_per_week>0 AND hours_per_week<=80)),
 start_date date NOT NULL,
 fixed_term_end date,
 fixed_term_exception text,                             -- AU: the Fair Work Act exception relied on for a term over two years
 trial_period_days integer CHECK(trial_period_days IS NULL OR trial_period_days>0),  -- NZ 90-day trial
 probation_end date,
 work_rights text NOT NULL DEFAULT 'citizen' CHECK(work_rights IN ('citizen','resident','visa')),
 visa_type text, visa_expires_on date,
 date_of_birth date,
 termination_date date, termination_reason text,
 source jsonb,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK(fixed_term_end IS NULL OR fixed_term_end>=start_date),
 CHECK(termination_date IS NULL OR termination_date>=start_date),
 CHECK(employment_type<>'fixed_term' OR fixed_term_end IS NOT NULL),
 CHECK(manager_id IS NULL OR manager_id<>id)
);

-- Employment agreements and their variations. signed_on is the day the employee signed.
CREATE TABLE agreements (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 kind text NOT NULL CHECK(kind IN ('employment_agreement','variation','fixed_term_renewal')),
 offered_on date, signed_on date, starts_on date, ends_on date,
 summary text, evidence text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);

-- AU information statements given (Fair Work Act ss125, 125A, 125B).
CREATE TABLE statements (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 kind text NOT NULL CHECK(kind IN ('FWIS','CEIS','FTCIS')),
 given_on date NOT NULL, evidence text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now()
);

-- A snapshot from payroll. One row per employee and leave type, replaced on each import.
CREATE TABLE leave_balances (
 employee_id uuid NOT NULL REFERENCES employees(id),
 leave_type text NOT NULL CHECK(leave_type IN ('annual','sick','personal','long_service','alternative')),
 hours numeric NOT NULL, as_at date NOT NULL,
 updated_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(employee_id,leave_type)
);

CREATE TABLE leave_requests (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 leave_type text NOT NULL CHECK(leave_type IN ('annual','sick','personal','long_service','alternative','bereavement','parental','family_violence','unpaid')),
 starts_on date NOT NULL, ends_on date NOT NULL, hours numeric CHECK(hours IS NULL OR hours>0),
 reason text,
 status text NOT NULL DEFAULT 'requested' CHECK(status IN ('requested','approved','declined','cancelled')),
 requested_on date NOT NULL DEFAULT current_date,
 decided_by text, decided_on date, decision_note text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK(ends_on>=starts_on)
);

CREATE TABLE policies (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 name text NOT NULL UNIQUE CHECK(length(trim(name))>0),
 version text NOT NULL DEFAULT '1',
 effective_on date NOT NULL,
 requires_ack boolean NOT NULL DEFAULT true,
 applies_to text NOT NULL DEFAULT 'all' CHECK(applies_to IN ('all','NZ','AU')),
 link text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE acknowledgements (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 policy_id uuid NOT NULL REFERENCES policies(id),
 version text NOT NULL,
 acknowledged_on date NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(employee_id,policy_id,version)
);

CREATE TABLE reviews (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 kind text NOT NULL CHECK(kind IN ('trial','probation','annual','one_on_one')),
 due_on date NOT NULL, completed_on date,
 reviewer text, outcome text, notes text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE certifications (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 name text NOT NULL CHECK(length(trim(name))>0),
 issued_on date, expires_on date,
 required boolean NOT NULL DEFAULT true,
 evidence text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK(expires_on IS NULL OR issued_on IS NULL OR expires_on>=issued_on)
);

-- Employee relations matters: performance, conduct, grievances, wellbeing. Kept short and factual.
CREATE TABLE cases (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 kind text NOT NULL CHECK(kind IN ('performance','misconduct','grievance','wellbeing','other')),
 opened_on date NOT NULL DEFAULT current_date,
 owner text NOT NULL,
 summary text NOT NULL,
 next_step text, next_step_due date,
 closed_on date, outcome text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE case_notes (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 case_id uuid NOT NULL REFERENCES cases(id),
 noted_on date NOT NULL DEFAULT current_date, note text NOT NULL, actor text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE tasks (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 employee_id uuid NOT NULL REFERENCES employees(id),
 kind text NOT NULL CHECK(kind IN ('onboarding','offboarding','other')),
 task text NOT NULL CHECK(length(trim(task))>0),
 owner text, due_on date NOT NULL, done_on date, evidence text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);

-- The checklist a hire or a leaver gets. Change it with /customise or plain inserts.
CREATE TABLE task_templates (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 kind text NOT NULL CHECK(kind IN ('onboarding','offboarding')),
 country text CHECK(country IN ('NZ','AU')),
 task text NOT NULL, owner text, days_from integer NOT NULL DEFAULT 0
);

CREATE TABLE settings (key text PRIMARY KEY, value numeric NOT NULL, note text NOT NULL);
INSERT INTO settings VALUES
('leave_decision_days',3,'Flag a leave request nobody has answered after this many days'),
('review_cycle_months',12,'Everyone past their first year gets an annual review at least this often'),
('cert_warning_days',30,'Flag a certification this many days before it expires'),
('visa_warning_days',60,'Flag a visa this many days before it expires'),
('ack_days',14,'Flag a policy not acknowledged this many days after it applies to someone'),
('trial_warning_days',14,'Flag a trial or probation this many days before it ends'),
('statement_grace_days',7,'Days after a start date or milestone to record an AU information statement'),
('large_leave_weeks',8,'Flag an annual leave balance above this many weeks of the person''s ordinary hours'),
('small_business_under',15,'AU: an employer with fewer employees than this is a small business employer (Fair Work Act s23)');

CREATE TABLE activity (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, record text NOT NULL, record_id text, action text NOT NULL, actor text NOT NULL,
 before_data jsonb, after_data jsonb, evidence text, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE imports (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, filename text NOT NULL, sha256 text NOT NULL, kind text NOT NULL,
 row_count integer NOT NULL, actor text NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER employers_touch BEFORE UPDATE ON employers FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER employees_touch BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER agreements_touch BEFORE UPDATE ON agreements FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER leave_balances_touch BEFORE UPDATE ON leave_balances FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER leave_requests_touch BEFORE UPDATE ON leave_requests FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER policies_touch BEFORE UPDATE ON policies FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER reviews_touch BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER certifications_touch BEFORE UPDATE ON certifications FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER cases_touch BEFORE UPDATE ON cases FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER tasks_touch BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION touch_updated();

CREATE INDEX employees_employer ON employees(employer_id);
CREATE INDEX employees_manager ON employees(manager_id);
CREATE INDEX leave_requests_employee ON leave_requests(employee_id,starts_on);
CREATE INDEX reviews_employee ON reviews(employee_id,due_on);
CREATE INDEX certifications_employee ON certifications(employee_id,expires_on);
CREATE INDEX tasks_employee ON tasks(employee_id,due_on);

-- ---------------------------------------------------------------- helpers
CREATE FUNCTION setting(k text) RETURNS numeric LANGUAGE sql STABLE AS $$ SELECT value FROM settings WHERE key=k $$;
-- Whole months of service from a start date to a day.
CREATE FUNCTION months_served(s date, d date) RETURNS integer LANGUAGE sql IMMUTABLE AS $$
 SELECT (extract(year FROM age(d,s))*12+extract(month FROM age(d,s)))::int $$;

-- ---------------------------------------------------------------- views
CREATE VIEW v_people AS
SELECT p.id, p.code, p.first_name||' '||p.last_name AS name, coalesce(p.preferred_name,p.first_name) AS known_as,
 p.employer_id, r.name AS employer, r.country, p.job_title, p.department, p.location,
 m.first_name||' '||m.last_name AS manager, p.manager_id, p.email, p.employment_type, p.hours_per_week,
 p.start_date, p.fixed_term_end, p.fixed_term_exception, p.trial_period_days, p.probation_end, p.work_rights, p.visa_type, p.visa_expires_on,
 p.termination_date, p.termination_reason,
 CASE WHEN p.termination_date IS NOT NULL AND p.termination_date<current_date THEN 'left'
      WHEN p.termination_date IS NOT NULL THEN 'leaving'
      WHEN p.start_date>current_date THEN 'starting' ELSE 'active' END AS status,
 months_served(p.start_date,least(current_date,coalesce(p.termination_date,current_date))) AS months_served
FROM employees p JOIN employers r ON r.id=p.employer_id LEFT JOIN employees m ON m.id=p.manager_id;

-- People on the books today or starting soon.
CREATE VIEW v_current AS SELECT * FROM v_people WHERE status IN ('active','leaving','starting');

-- Fair Work Act s23: fewer than 15 employees, counting casuals only when regular and systematic.
-- Casuals are left out here; count them in by changing this view with /customise.
CREATE VIEW v_employer_size AS
SELECT r.id AS employer_id, r.name AS employer, r.country,
 count(p.id) FILTER (WHERE p.status IN ('active','leaving')) AS headcount,
 count(p.id) FILTER (WHERE p.status IN ('active','leaving') AND p.employment_type<>'casual') AS counted_for_size,
 count(p.id) FILTER (WHERE p.status IN ('active','leaving') AND p.employment_type<>'casual')<setting('small_business_under') AS small_business
FROM employers r LEFT JOIN v_people p ON p.employer_id=r.id GROUP BY r.id,r.name,r.country;

CREATE VIEW v_headcount AS
SELECT employer, coalesce(department,'(none)') AS department,
 count(*) FILTER (WHERE employment_type='full_time') AS full_time,
 count(*) FILTER (WHERE employment_type='part_time') AS part_time,
 count(*) FILTER (WHERE employment_type='casual') AS casual,
 count(*) FILTER (WHERE employment_type='fixed_term') AS fixed_term,
 count(*) AS total,
 round(sum(coalesce(hours_per_week,0))/40.0,1) AS fte_at_40_hours
FROM v_people WHERE status IN ('active','leaving') GROUP BY employer,department;

CREATE VIEW v_turnover AS
SELECT r.name AS employer,
 count(p.id) FILTER (WHERE p.termination_date BETWEEN current_date-365 AND current_date) AS left_last_12_months,
 count(p.id) FILTER (WHERE p.termination_date BETWEEN current_date-365 AND current_date AND p.months_served<12) AS left_in_first_year,
 round(avg(count_on.n),1) AS average_headcount,
 round(100.0*count(p.id) FILTER (WHERE p.termination_date BETWEEN current_date-365 AND current_date)/nullif(avg(count_on.n),0),1) AS turnover_pct
FROM employers r LEFT JOIN v_people p ON p.employer_id=r.id
CROSS JOIN LATERAL (SELECT (count(*) FILTER (WHERE e.start_date<=current_date-365 AND (e.termination_date IS NULL OR e.termination_date>current_date-365))
  +count(*) FILTER (WHERE e.start_date<=current_date AND (e.termination_date IS NULL OR e.termination_date>current_date)))/2.0 AS n
  FROM employees e WHERE e.employer_id=r.id) count_on
GROUP BY r.name;

CREATE VIEW v_leave_open AS
SELECT q.id, p.name, p.employer, p.manager, q.leave_type, q.starts_on, q.ends_on, q.hours, q.status, q.requested_on,
 (current_date-q.requested_on) AS days_waiting, q.reason, q.employee_id
FROM leave_requests q JOIN v_people p ON p.id=q.employee_id
WHERE q.status='requested';

CREATE VIEW v_away AS
SELECT p.name, p.employer, p.department, p.manager, q.leave_type, q.starts_on, q.ends_on, q.hours, q.employee_id
FROM leave_requests q JOIN v_people p ON p.id=q.employee_id
WHERE q.status='approved' AND q.ends_on>=current_date AND q.starts_on<=current_date+14;

CREATE VIEW v_balances AS
SELECT p.name, p.employer, p.country, b.leave_type, b.hours, p.hours_per_week,
 round(b.hours/nullif(p.hours_per_week,0),1) AS weeks, b.as_at,
 (b.leave_type='annual' AND b.hours/nullif(p.hours_per_week,0)>setting('large_leave_weeks')) AS large, b.employee_id
FROM leave_balances b JOIN v_people p ON p.id=b.employee_id WHERE p.status IN ('active','leaving');

CREATE VIEW v_reviews AS
SELECT r.id, p.name, p.employer, p.manager, r.kind, r.due_on, r.reviewer,
 CASE WHEN r.due_on<current_date THEN 'overdue' WHEN r.due_on<=current_date+14 THEN 'due soon' ELSE 'booked' END AS state,
 (current_date-r.due_on) AS days_overdue, r.employee_id
FROM reviews r JOIN v_people p ON p.id=r.employee_id
WHERE r.completed_on IS NULL AND p.status IN ('active','leaving','starting');

-- Past their first year with no annual review completed inside the cycle and none booked.
CREATE VIEW v_review_gaps AS
SELECT p.id AS employee_id, p.name, p.employer, p.manager, p.start_date,
 (SELECT max(completed_on) FROM reviews r WHERE r.employee_id=p.id AND r.kind='annual') AS last_annual_review
FROM v_people p
WHERE p.status='active' AND p.months_served>=setting('review_cycle_months')
 AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.employee_id=p.id AND r.kind='annual' AND r.completed_on>=current_date-(setting('review_cycle_months')::int*interval '1 month'))
 AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.employee_id=p.id AND r.kind='annual' AND r.completed_on IS NULL);

-- NZ trial periods and probation periods, with when they end and whether a review is done.
CREATE VIEW v_trials AS
SELECT p.id AS employee_id, p.name, p.employer, p.country, p.manager,
 CASE WHEN p.trial_period_days IS NOT NULL THEN 'trial ('||p.trial_period_days||' days)' ELSE 'probation' END AS kind,
 p.start_date, coalesce(p.start_date+p.trial_period_days-1,p.probation_end) AS ends_on,
 (coalesce(p.start_date+p.trial_period_days-1,p.probation_end)-current_date) AS days_left,
 EXISTS (SELECT 1 FROM reviews r WHERE r.employee_id=p.id AND r.kind IN ('trial','probation') AND r.completed_on IS NOT NULL) AS reviewed
FROM v_people p
WHERE p.status IN ('active','leaving','starting') AND (p.trial_period_days IS NOT NULL OR p.probation_end IS NOT NULL)
 AND coalesce(p.start_date+p.trial_period_days-1,p.probation_end)>=current_date-30;

CREATE VIEW v_certs AS
SELECT c.id, p.name, p.employer, p.job_title, c.name AS certification, c.issued_on, c.expires_on, c.required,
 CASE WHEN c.expires_on IS NULL THEN 'no expiry' WHEN c.expires_on<current_date THEN 'expired'
      WHEN c.expires_on<=current_date+setting('cert_warning_days')::int THEN 'expiring' ELSE 'current' END AS state,
 (c.expires_on-current_date) AS days_left, c.employee_id
FROM certifications c JOIN v_people p ON p.id=c.employee_id WHERE p.status IN ('active','leaving','starting');

-- Policies that apply to a person, not yet acknowledged at the current version.
CREATE VIEW v_policy_gaps AS
SELECT p.id AS employee_id, p.name, p.employer, p.manager, pol.name AS policy, pol.version,
 greatest(pol.effective_on,p.start_date) AS applies_from, (current_date-greatest(pol.effective_on,p.start_date)) AS days_open
FROM v_people p JOIN policies pol ON pol.requires_ack AND (pol.applies_to='all' OR pol.applies_to=p.country)
WHERE p.status IN ('active','leaving') AND greatest(pol.effective_on,p.start_date)<=current_date
 AND NOT EXISTS (SELECT 1 FROM acknowledgements a WHERE a.employee_id=p.id AND a.policy_id=pol.id AND a.version=pol.version);

CREATE VIEW v_cases AS
SELECT c.id, p.name, p.employer, c.kind, c.opened_on, c.owner, c.summary, c.next_step, c.next_step_due,
 (current_date-c.next_step_due) AS days_overdue, (SELECT max(noted_on) FROM case_notes n WHERE n.case_id=c.id) AS last_note, c.employee_id
FROM cases c JOIN v_people p ON p.id=c.employee_id WHERE c.closed_on IS NULL;

CREATE VIEW v_tasks AS
SELECT t.id, p.name, p.employer, t.kind, t.task, t.owner, t.due_on,
 CASE WHEN t.due_on<current_date THEN 'overdue' ELSE 'open' END AS state, t.employee_id
FROM tasks t JOIN v_people p ON p.id=t.employee_id WHERE t.done_on IS NULL;

CREATE VIEW v_anniversaries AS
SELECT p.name, p.employer, p.department, p.manager, p.start_date,
 (p.start_date+((months_served(p.start_date,current_date)/12+1)*interval '1 year'))::date AS anniversary,
 months_served(p.start_date,current_date)/12+1 AS years
FROM v_people p WHERE p.status='active'
 AND (p.start_date+((months_served(p.start_date,current_date)/12+1)*interval '1 year'))::date<=current_date+30;

-- ---------------------------------------------------------------- AU information statements
-- The date the latest statement fell due. CEIS: at start for everyone; then at 12 months for a small
-- business employer; at 6 months, 12 months and every 12 months after for everyone else (s125A, from
-- 26 August 2024).
CREATE VIEW v_statements_due AS
SELECT p.id AS employee_id, p.name, p.employer, 'FWIS' AS kind, p.start_date AS due_from
 FROM v_people p WHERE p.country='AU' AND p.status IN ('active','leaving')
UNION ALL
SELECT p.id, p.name, p.employer, 'FTCIS', p.start_date
 FROM v_people p WHERE p.country='AU' AND p.status IN ('active','leaving') AND p.employment_type='fixed_term'
UNION ALL
SELECT p.id, p.name, p.employer, 'CEIS',
 CASE WHEN s.small_business THEN CASE WHEN p.months_served>=12 THEN (p.start_date+interval '12 months')::date ELSE p.start_date END
      WHEN p.months_served>=12 THEN (p.start_date+(p.months_served/12)*interval '12 months')::date
      WHEN p.months_served>=6 THEN (p.start_date+interval '6 months')::date ELSE p.start_date END
 FROM v_people p JOIN v_employer_size s ON s.employer_id=p.employer_id
 WHERE p.country='AU' AND p.status IN ('active','leaving') AND p.employment_type='casual';

-- ---------------------------------------------------------------- compliance
CREATE VIEW v_compliance AS
-- NZ: every employee has a written agreement, and the employer keeps a signed copy (ERA ss63A, 64, 65).
SELECT 'NZ-WRITTEN-AGREEMENT' AS rule, p.name||' ('||p.employer||')' AS item,
 'No signed employment agreement on file. Started '||p.start_date AS finding
FROM v_people p WHERE p.country='NZ' AND p.status IN ('active','leaving')
 AND NOT EXISTS (SELECT 1 FROM agreements a WHERE a.employee_id=p.id AND a.kind='employment_agreement' AND a.signed_on IS NOT NULL)
UNION ALL
-- NZ: a trial period is up to 90 days, in writing, agreed before the employee starts work (ERA s67A).
SELECT 'NZ-TRIAL-PERIOD', p.name||' ('||p.employer||')',
 CASE WHEN p.trial_period_days>90 THEN 'Trial period of '||p.trial_period_days||' days is longer than 90'
      WHEN a.signed_on IS NULL THEN 'Trial period recorded but no signed agreement holds it'
      ELSE 'Trial clause signed '||a.signed_on||', after starting '||p.start_date END
FROM v_people p LEFT JOIN LATERAL (SELECT min(signed_on) AS signed_on FROM agreements x WHERE x.employee_id=p.id AND x.kind='employment_agreement') a ON true
WHERE p.country='NZ' AND p.trial_period_days IS NOT NULL AND p.status IN ('active','leaving','starting')
 AND (p.trial_period_days>90 OR a.signed_on IS NULL OR a.signed_on>=p.start_date)
UNION ALL
-- NZ: accredited employers may not put a trial period in an AEWV holder's agreement (Immigration NZ, from 29 Oct 2023).
SELECT 'NZ-AEWV-TRIAL', p.name||' ('||p.employer||')', 'Trial period in an AEWV holder''s agreement (accredited employer)'
FROM v_people p JOIN employers r ON r.id=p.employer_id
WHERE p.country='NZ' AND r.accredited_employer AND p.trial_period_days IS NOT NULL AND upper(coalesce(p.visa_type,''))='AEWV' AND p.status IN ('active','leaving','starting')
UNION ALL
-- AU: FWIS to every new employee, FTCIS to fixed-term employees, CEIS to casuals on the schedule (FW Act ss125, 125A, 125B).
SELECT 'AU-'||d.kind, d.name||' ('||d.employer||')',
 d.kind||' due '||d.due_from||CASE WHEN last.given_on IS NOT NULL THEN ', last given '||last.given_on ELSE ', never recorded as given' END
FROM v_statements_due d LEFT JOIN LATERAL (SELECT max(given_on) AS given_on FROM statements s WHERE s.employee_id=d.employee_id AND s.kind=d.kind) last ON true
WHERE (last.given_on IS NULL OR last.given_on<d.due_from-30) AND current_date>d.due_from+setting('statement_grace_days')::int
UNION ALL
-- AU: a fixed-term contract may not run past two years or be renewed more than once, unless an exception applies (FW Act s333E, from 6 Dec 2023).
SELECT 'AU-FIXED-TERM-LIMIT', p.name||' ('||p.employer||')',
 CASE WHEN p.fixed_term_end>(p.start_date+interval '2 years')::date THEN 'Fixed term runs '||p.start_date||' to '||p.fixed_term_end||', more than two years'
      ELSE 'Fixed-term contract renewed '||(SELECT count(*) FROM agreements a WHERE a.employee_id=p.id AND a.kind='fixed_term_renewal')||' times' END
FROM v_people p WHERE p.country='AU' AND p.employment_type='fixed_term' AND p.status IN ('active','leaving','starting')
 AND p.start_date>='2023-12-06' AND p.fixed_term_exception IS NULL
 AND (p.fixed_term_end>(p.start_date+interval '2 years')::date OR (SELECT count(*) FROM agreements a WHERE a.employee_id=p.id AND a.kind='fixed_term_renewal')>1)
UNION ALL
-- NZ and AU: no one works without the right to (NZ Immigration Act 2009 s350; AU Migration Act 1958 s245AB).
SELECT 'RIGHT-TO-WORK', p.name||' ('||p.employer||')',
 CASE WHEN p.visa_expires_on IS NULL THEN 'Works on a visa with no expiry date recorded' ELSE 'Visa ('||coalesce(p.visa_type,'type not recorded')||') expired '||p.visa_expires_on END
FROM v_people p WHERE p.work_rights='visa' AND p.status IN ('active','leaving','starting') AND (p.visa_expires_on IS NULL OR p.visa_expires_on<current_date)
UNION ALL
-- NZ HSWA 2015 s36 and AU WHS Act 2011 s19: a required licence or ticket has lapsed.
SELECT 'REQUIRED-CERTIFICATION', c.name||' ('||c.employer||')', c.certification||' expired '||c.expires_on
FROM v_certs c WHERE c.required AND c.state='expired';

-- ---------------------------------------------------------------- attention
CREATE VIEW v_attention AS
SELECT name||': '||leave_type||' leave '||starts_on||' to '||ends_on AS item, 'leave waiting' AS issue,
 'Requested '||days_waiting||' days ago, manager '||coalesce(manager,'not recorded') AS detail
FROM v_leave_open WHERE days_waiting>=setting('leave_decision_days')
UNION ALL
SELECT name||': '||replace(kind,'_','-')||' review', 'review overdue', 'Due '||due_on||', '||days_overdue||' days ago, reviewer '||coalesce(reviewer,'not recorded') FROM v_reviews WHERE state='overdue'
UNION ALL
SELECT name, 'no annual review', 'Started '||start_date||', last annual review '||coalesce(last_annual_review::text,'never')||', none booked' FROM v_review_gaps
UNION ALL
SELECT name||': '||kind, 'trial or probation ending', 'Ends '||ends_on||' ('||days_left||' days) with no review recorded'
FROM v_trials WHERE NOT reviewed AND days_left BETWEEN 0 AND setting('trial_warning_days')
UNION ALL
SELECT name||': '||certification, 'certification expiring', 'Expires '||expires_on||' ('||days_left||' days)' FROM v_certs WHERE state='expiring'
UNION ALL
SELECT p.name, 'visa expiring', coalesce(p.visa_type,'Visa')||' expires '||p.visa_expires_on||' ('||(p.visa_expires_on-current_date)||' days)'
FROM v_people p WHERE p.work_rights='visa' AND p.status IN ('active','leaving','starting') AND p.visa_expires_on BETWEEN current_date AND current_date+setting('visa_warning_days')::int
UNION ALL
SELECT name||': '||policy, 'policy not acknowledged', 'Version '||version||', open '||days_open||' days' FROM v_policy_gaps WHERE days_open>=setting('ack_days')
UNION ALL
SELECT name||': '||kind||' case', 'case step overdue', coalesce(next_step,'Next step not recorded')||', due '||coalesce(next_step_due::text,'no date')||', owner '||owner
FROM v_cases WHERE next_step_due IS NULL OR next_step_due<current_date
UNION ALL
SELECT name||': '||task, kind||' task overdue', 'Due '||due_on||', owner '||coalesce(owner,'not recorded') FROM v_tasks WHERE state='overdue'
UNION ALL
SELECT name, 'large leave balance', hours||' hours of annual leave, '||weeks||' weeks, as at '||as_at FROM v_balances WHERE large
UNION ALL
SELECT p.name, 'leaving', 'Last day '||p.termination_date||', '||(SELECT count(*) FROM tasks t WHERE t.employee_id=p.id AND t.kind='offboarding' AND t.done_on IS NULL)||' offboarding tasks open'
FROM v_people p WHERE p.status='leaving' AND p.termination_date<=current_date+14;
