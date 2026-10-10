-- Fictional demo: Totara Foods, an NZ food manufacturer (an accredited employer) with a small Australian
-- sales and distribution company. Dates move with today, so the demo always has something to say.
-- Deliberately untidy: a forklift driver whose licence has lapsed, a visa that has expired, another about
-- to, a trial period signed after the start date, a trial period in an AEWV holder's agreement, a sales
-- coordinator with no signed agreement, a casual overdue for the 12-month CEIS, a fixed-term contract
-- past two years with no FTCIS, a new starter with no FWIS, a leave request nobody has answered, an
-- overdue review, a trial ending with no review, a large annual leave balance, a case step overdue, and
-- a leaver with offboarding still open.
INSERT INTO employers(id,name,country,accredited_employer,eh_name) VALUES
('10000000-0000-4000-8000-000000000001','Totara Foods NZ Ltd','NZ',true,'Totara Foods NZ'),
('10000000-0000-4000-8000-000000000002','Totara Foods Australia Pty Ltd','AU',false,'Totara Foods AU')
ON CONFLICT DO NOTHING;

INSERT INTO employees(id,employer_id,code,first_name,last_name,email,job_title,department,location,manager_id,employment_type,hours_per_week,start_date,fixed_term_end,trial_period_days,probation_end,work_rights,visa_type,visa_expires_on,termination_date,termination_reason) VALUES
('20000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001','N01','Aroha','Walker','aroha@totarafoods.example','General Manager','Leadership','Hamilton',NULL,'full_time',40,current_date-interval '6 years 2 months',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000001','N02','Ben','Fifita','ben@totarafoods.example','Operations Manager','Operations','Hamilton','20000000-0000-4000-8000-000000000001','full_time',40,current_date-interval '4 years 1 month',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000001','N03','Mere','Tane','mere@totarafoods.example','People and Payroll Advisor','People','Hamilton','20000000-0000-4000-8000-000000000001','full_time',40,current_date-interval '3 years 4 months',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000001','N04','Daniel','Kim','daniel@totarafoods.example','Production Supervisor','Operations','Hamilton','20000000-0000-4000-8000-000000000002','full_time',40,current_date-interval '2 years 3 months',NULL,NULL,NULL,'visa','AEWV',current_date+40,NULL,NULL),
('20000000-0000-4000-8000-000000000005','10000000-0000-4000-8000-000000000001','N05','Priya','Sharma','priya@totarafoods.example','Food Technologist','Quality','Hamilton','20000000-0000-4000-8000-000000000002','full_time',40,current_date-35,NULL,90,NULL,'resident',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000006','10000000-0000-4000-8000-000000000001','N06','Sam','Tuilagi','sam.t@totarafoods.example','Forklift Operator','Warehouse','Hamilton','20000000-0000-4000-8000-000000000008','full_time',40,current_date-interval '1 year 8 months',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000007','10000000-0000-4000-8000-000000000001','N07','Lucy','Brown','lucy@totarafoods.example','Packer','Operations','Hamilton','20000000-0000-4000-8000-000000000004','part_time',24,current_date-80,NULL,90,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000008','10000000-0000-4000-8000-000000000001','N08','Hemi','Rawiri','hemi@totarafoods.example','Warehouse Lead','Warehouse','Hamilton','20000000-0000-4000-8000-000000000002','full_time',40,current_date-interval '7 years 5 months',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000009','10000000-0000-4000-8000-000000000001','N09','Grace','Liu','grace@totarafoods.example','Sales Coordinator','Sales','Auckland','20000000-0000-4000-8000-000000000001','full_time',40,current_date-interval '14 months',NULL,NULL,NULL,'resident',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000010','10000000-0000-4000-8000-000000000001','N10','Tom','Wilson','tom@totarafoods.example','Delivery Driver','Warehouse','Hamilton','20000000-0000-4000-8000-000000000008','casual',NULL,current_date-interval '2 years',NULL,NULL,NULL,'citizen',NULL,NULL,current_date+7,'Resigned: moving to Tauranga'),
('20000000-0000-4000-8000-000000000011','10000000-0000-4000-8000-000000000001','N11','Ana','Lopez','ana@totarafoods.example','Marketing Coordinator','Sales','Auckland','20000000-0000-4000-8000-000000000001','full_time',40,current_date-interval '10 months',NULL,NULL,NULL,'citizen',NULL,NULL,current_date-100,'Resigned: new role'),
('20000000-0000-4000-8000-000000000012','10000000-0000-4000-8000-000000000001','N12','Kai','Parata','kai@totarafoods.example','Production Operator','Operations','Hamilton','20000000-0000-4000-8000-000000000004','full_time',40,current_date-20,NULL,90,NULL,'visa','AEWV',current_date+interval '2 years',NULL,NULL),
('20000000-0000-4000-8000-000000000021','10000000-0000-4000-8000-000000000002','A01','Jess','Morgan','jess@totarafoods.example','Country Manager','Leadership','Melbourne','20000000-0000-4000-8000-000000000001','full_time',38,current_date-interval '3 years',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000022','10000000-0000-4000-8000-000000000002','A02','Liam','O''Brien','liam@totarafoods.example','Sales Representative','Sales','Melbourne','20000000-0000-4000-8000-000000000021','full_time',38,current_date-interval '2 years 1 month',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000023','10000000-0000-4000-8000-000000000002','A03','Chloe','Nguyen','chloe@totarafoods.example','Warehouse Hand','Warehouse','Melbourne','20000000-0000-4000-8000-000000000021','casual',NULL,current_date-interval '13 months',NULL,NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000024','10000000-0000-4000-8000-000000000002','A04','Ravi','Patel','ravi@totarafoods.example','Systems Project Analyst','Leadership','Melbourne','20000000-0000-4000-8000-000000000021','fixed_term',38,current_date-interval '10 months',current_date+interval '20 months',NULL,NULL,'citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000025','10000000-0000-4000-8000-000000000002','A05','Emily','Scott','emily@totarafoods.example','Customer Service Officer','Sales','Melbourne','20000000-0000-4000-8000-000000000021','part_time',30,current_date-20,NULL,NULL,current_date+interval '5 months','citizen',NULL,NULL,NULL,NULL),
('20000000-0000-4000-8000-000000000026','10000000-0000-4000-8000-000000000002','A06','Noah','Smith','noah@totarafoods.example','Delivery Driver','Warehouse','Melbourne','20000000-0000-4000-8000-000000000021','full_time',38,current_date-interval '1 year 6 months',NULL,NULL,NULL,'visa','Skills in Demand (482)',current_date-5,NULL,NULL)
ON CONFLICT DO NOTHING;

INSERT INTO agreements(id,employee_id,kind,offered_on,signed_on,starts_on,summary,evidence) VALUES
('30000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001','employment_agreement',current_date-interval '6 years 3 months',current_date-interval '6 years 3 months',current_date-interval '6 years 2 months','Individual employment agreement, General Manager','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000002','employment_agreement',current_date-interval '4 years 2 months',current_date-interval '4 years 2 months',current_date-interval '4 years 1 month','Individual employment agreement','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000003','employment_agreement',current_date-interval '3 years 5 months',current_date-interval '3 years 5 months',current_date-interval '3 years 4 months','Individual employment agreement','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000004','employment_agreement',current_date-interval '2 years 4 months',current_date-interval '2 years 4 months',current_date-interval '2 years 3 months','Individual employment agreement, no trial period','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000005','employment_agreement',current_date-45,current_date-33,current_date-35,'Individual employment agreement with a 90-day trial period','Signed PDF returned two days after starting'),
('30000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000006','employment_agreement',current_date-interval '1 year 9 months',current_date-interval '1 year 9 months',current_date-interval '1 year 8 months','Individual employment agreement','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000007','employment_agreement',current_date-95,current_date-90,current_date-80,'Part-time agreement, 24 hours, 90-day trial period','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000008','20000000-0000-4000-8000-000000000008','employment_agreement',current_date-interval '7 years 6 months',current_date-interval '7 years 6 months',current_date-interval '7 years 5 months','Individual employment agreement','Paper copy in the HR cabinet'),
('30000000-0000-4000-8000-000000000009','20000000-0000-4000-8000-000000000009','employment_agreement',current_date-interval '14 months 7 days',NULL,current_date-interval '14 months','Individual employment agreement, sent and never returned signed',NULL),
('30000000-0000-4000-8000-000000000010','20000000-0000-4000-8000-000000000010','employment_agreement',current_date-interval '2 years 7 days',current_date-interval '2 years 5 days',current_date-interval '2 years','Casual agreement','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000011','20000000-0000-4000-8000-000000000011','employment_agreement',current_date-interval '10 months 10 days',current_date-interval '10 months 8 days',current_date-interval '10 months','Individual employment agreement','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000012','20000000-0000-4000-8000-000000000012','employment_agreement',current_date-30,current_date-27,current_date-20,'Individual employment agreement with a 90-day trial period','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000021','20000000-0000-4000-8000-000000000021','employment_agreement',current_date-interval '3 years 1 month',current_date-interval '3 years 1 month',current_date-interval '3 years','Contract of employment, award free','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000022','20000000-0000-4000-8000-000000000022','employment_agreement',current_date-interval '2 years 2 months',current_date-interval '2 years 2 months',current_date-interval '2 years 1 month','Contract of employment','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000023','20000000-0000-4000-8000-000000000023','employment_agreement',current_date-interval '13 months 5 days',current_date-interval '13 months 3 days',current_date-interval '13 months','Casual contract','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000024','20000000-0000-4000-8000-000000000024','employment_agreement',current_date-interval '10 months 14 days',current_date-interval '10 months 10 days',current_date-interval '10 months','Fixed-term contract, 30 months, systems replacement project','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000025','20000000-0000-4000-8000-000000000025','employment_agreement',current_date-30,current_date-25,current_date-20,'Part-time contract, 30 hours, six-month probation','Signed PDF in the people drive'),
('30000000-0000-4000-8000-000000000026','20000000-0000-4000-8000-000000000026','employment_agreement',current_date-interval '1 year 7 months',current_date-interval '1 year 7 months',current_date-interval '1 year 6 months','Contract of employment','Signed PDF in the people drive')
ON CONFLICT DO NOTHING;

INSERT INTO statements(id,employee_id,kind,given_on,evidence) VALUES
('40000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000021','FWIS',current_date-interval '3 years','Emailed with the contract'),
('40000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000022','FWIS',current_date-interval '2 years 1 month','Emailed with the contract'),
('40000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000023','FWIS',current_date-interval '13 months','Emailed with the contract'),
('40000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000023','CEIS',current_date-interval '13 months','Emailed with the contract'),
('40000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000024','FWIS',current_date-interval '10 months','Emailed with the contract'),
('40000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000026','FWIS',current_date-interval '1 year 6 months','Emailed with the contract')
ON CONFLICT DO NOTHING;

INSERT INTO leave_balances(employee_id,leave_type,hours,as_at) VALUES
('20000000-0000-4000-8000-000000000001','annual',200,current_date-3),('20000000-0000-4000-8000-000000000001','sick',80,current_date-3),
('20000000-0000-4000-8000-000000000002','annual',120,current_date-3),('20000000-0000-4000-8000-000000000002','sick',80,current_date-3),
('20000000-0000-4000-8000-000000000003','annual',96,current_date-3),('20000000-0000-4000-8000-000000000003','sick',64,current_date-3),
('20000000-0000-4000-8000-000000000004','annual',80,current_date-3),('20000000-0000-4000-8000-000000000004','sick',32,current_date-3),
('20000000-0000-4000-8000-000000000006','annual',64,current_date-3),('20000000-0000-4000-8000-000000000006','sick',80,current_date-3),
('20000000-0000-4000-8000-000000000008','annual',360,current_date-3),('20000000-0000-4000-8000-000000000008','sick',160,current_date-3),
('20000000-0000-4000-8000-000000000009','annual',52,current_date-3),
('20000000-0000-4000-8000-000000000021','annual',150,current_date-3),('20000000-0000-4000-8000-000000000021','personal',60,current_date-3),('20000000-0000-4000-8000-000000000021','long_service',0,current_date-3),
('20000000-0000-4000-8000-000000000022','annual',110,current_date-3),('20000000-0000-4000-8000-000000000022','personal',45,current_date-3),
('20000000-0000-4000-8000-000000000024','annual',95,current_date-3),
('20000000-0000-4000-8000-000000000026','annual',140,current_date-3)
ON CONFLICT DO NOTHING;

INSERT INTO leave_requests(id,employee_id,leave_type,starts_on,ends_on,hours,reason,status,requested_on,decided_by,decided_on) VALUES
('50000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000006','annual',current_date+21,current_date+25,40,'Family wedding in Apia','requested',current_date-6,NULL,NULL),
('50000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000022','annual',current_date+40,current_date+44,38,'School holidays','requested',current_date-1,NULL,NULL),
('50000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000003','annual',current_date-1,current_date+3,40,NULL,'approved',current_date-30,'Aroha Walker',current_date-29),
('50000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000004','sick',current_date-1,current_date,16,NULL,'approved',current_date-1,'Ben Fifita',current_date-1),
('50000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000008','annual',current_date+5,current_date+9,40,'Fishing trip','declined',current_date-12,'Ben Fifita',current_date-10),
('50000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000021','annual',current_date+10,current_date+12,22.8,NULL,'approved',current_date-14,'Aroha Walker',current_date-13)
ON CONFLICT DO NOTHING;

INSERT INTO policies(id,name,version,effective_on,requires_ack,applies_to,link) VALUES
('60000000-0000-4000-8000-000000000001','Code of Conduct','3',current_date-interval '2 years',true,'all','https://intranet.totarafoods.example/policies/code-of-conduct'),
('60000000-0000-4000-8000-000000000002','Health and Safety Policy','2',current_date-16,true,'all','https://intranet.totarafoods.example/policies/health-and-safety'),
('60000000-0000-4000-8000-000000000003','Drug and Alcohol Policy','1',current_date-interval '3 years',true,'NZ','https://intranet.totarafoods.example/policies/drug-and-alcohol')
ON CONFLICT DO NOTHING;

-- Everyone current has acknowledged everything that applies to them, except the gaps below.
INSERT INTO acknowledgements(employee_id,policy_id,version,acknowledged_on)
SELECT p.id,pol.id,pol.version,greatest(pol.effective_on,p.start_date)+2
FROM employees p JOIN employers r ON r.id=p.employer_id JOIN policies pol ON pol.applies_to IN ('all',r.country)
WHERE (p.termination_date IS NULL OR p.termination_date>=current_date) AND greatest(pol.effective_on,p.start_date)+2<=current_date
 AND (p.code,pol.name) NOT IN (('N09','Code of Conduct'),('A05','Code of Conduct'),('N06','Health and Safety Policy'),('A03','Health and Safety Policy'),('N12','Health and Safety Policy'))
ON CONFLICT DO NOTHING;

INSERT INTO reviews(id,employee_id,kind,due_on,completed_on,reviewer,outcome,notes) VALUES
('70000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001','annual',current_date-95,current_date-90,'Board chair','Meets expectations','Targets set for the new line'),
('70000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000002','annual',current_date-20,NULL,'Aroha Walker',NULL,NULL),
('70000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000003','annual',current_date+10,NULL,'Aroha Walker',NULL,NULL),
('70000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000004','annual',current_date-62,current_date-60,'Ben Fifita','Exceeds expectations','Ready for the shift manager role'),
('70000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000005','trial',current_date+50,NULL,'Ben Fifita',NULL,NULL),
('70000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000008','annual',current_date-335,current_date-330,'Ben Fifita','Meets expectations',NULL),
('70000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000009','annual',current_date+30,NULL,'Aroha Walker',NULL,NULL),
('70000000-0000-4000-8000-000000000008','20000000-0000-4000-8000-000000000021','annual',current_date-152,current_date-150,'Aroha Walker','Meets expectations',NULL),
('70000000-0000-4000-8000-000000000009','20000000-0000-4000-8000-000000000022','annual',current_date-182,current_date-180,'Jess Morgan','Meets expectations',NULL),
('70000000-0000-4000-8000-000000000010','20000000-0000-4000-8000-000000000026','annual',current_date-122,current_date-120,'Jess Morgan','Meets expectations',NULL),
('70000000-0000-4000-8000-000000000011','20000000-0000-4000-8000-000000000004','one_on_one',current_date-3,NULL,'Ben Fifita',NULL,NULL),
('70000000-0000-4000-8000-000000000012','20000000-0000-4000-8000-000000000025','probation',current_date-14+interval '5 months',NULL,'Jess Morgan',NULL,NULL)
ON CONFLICT DO NOTHING;

INSERT INTO certifications(id,employee_id,name,issued_on,expires_on,required,evidence) VALUES
('80000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000006','Forklift operator certificate (F endorsement)',current_date-interval '3 years 10 days',current_date-10,true,'Copy on file'),
('80000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000004','First aid certificate',current_date+20-interval '2 years',current_date+20,true,'Copy on file'),
('80000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000002','First aid certificate',current_date-330,current_date+400,true,'Copy on file'),
('80000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000008','Forklift operator certificate (F endorsement)',current_date-200-interval '2 years',current_date+200,true,'Copy on file'),
('80000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000023','High risk work licence (LF forklift)',current_date+900-interval '4 years',current_date+900,true,'Sighted, copy on file'),
('80000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000026','Heavy rigid driver licence (HR)',current_date-interval '5 years',current_date+300,true,'Sighted, copy on file'),
('80000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000005','Food safety: HACCP level 4',current_date-interval '4 years',NULL,false,'Certificate on file')
ON CONFLICT DO NOTHING;

INSERT INTO cases(id,employee_id,kind,opened_on,owner,summary,next_step,next_step_due) VALUES
('90000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000009','performance',current_date-40,'Mere Tane','Customer orders entered late three weeks running; agreed support plan','Second meeting, support person invited, letter sent five days before',current_date-5)
ON CONFLICT DO NOTHING;
INSERT INTO case_notes(id,case_id,noted_on,note,actor) VALUES
('91000000-0000-4000-8000-000000000001','90000000-0000-4000-8000-000000000001',current_date-40,'First informal meeting. Grace said the order inbox is shared with Auckland and nobody owns it. Support plan agreed: own the inbox, daily check at 10am.','Mere Tane'),
('91000000-0000-4000-8000-000000000002','90000000-0000-4000-8000-000000000001',current_date-19,'Two more late orders. Second meeting to be booked.','Mere Tane')
ON CONFLICT DO NOTHING;

INSERT INTO tasks(id,employee_id,kind,task,owner,due_on,done_on,evidence) VALUES
('a0000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000025','onboarding','Give the Fair Work Information Statement','Jess Morgan',current_date-20,NULL,NULL),
('a0000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000025','onboarding','TFN declaration and super choice form to payroll','Jess Morgan',current_date-20,current_date-19,'Sent to payroll'),
('a0000000-0000-4000-8000-000000000003','20000000-0000-4000-8000-000000000012','onboarding','Site induction and health and safety briefing','Ben Fifita',current_date-20,NULL,NULL),
('a0000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000012','onboarding','Tax code declaration (IR330) and KiwiSaver details to payroll','Mere Tane',current_date-20,current_date-20,'Sent to payroll'),
('a0000000-0000-4000-8000-000000000005','20000000-0000-4000-8000-000000000010','offboarding','Return keys, fuel card and hi-vis','Hemi Rawiri',current_date+7,NULL,NULL),
('a0000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000010','offboarding','Final pay and holiday pay to payroll','Mere Tane',current_date+7,NULL,NULL),
('a0000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000010','offboarding','Confirm resignation and last day in writing','Mere Tane',current_date-7,current_date-8,'Letter emailed')
ON CONFLICT DO NOTHING;

INSERT INTO task_templates(id,kind,country,task,owner,days_from) VALUES
('b0000000-0000-4000-8000-000000000001','onboarding','NZ','Signed employment agreement on file before day one',NULL,-1),
('b0000000-0000-4000-8000-000000000002','onboarding','NZ','Tax code declaration (IR330) and KiwiSaver details to payroll',NULL,0),
('b0000000-0000-4000-8000-000000000003','onboarding','AU','Give the Fair Work Information Statement',NULL,0),
('b0000000-0000-4000-8000-000000000004','onboarding','AU','TFN declaration and super choice form to payroll',NULL,0),
('b0000000-0000-4000-8000-000000000005','onboarding',NULL,'Site induction and health and safety briefing',NULL,0),
('b0000000-0000-4000-8000-000000000006','onboarding',NULL,'Right to work checked and recorded',NULL,0),
('b0000000-0000-4000-8000-000000000007','onboarding',NULL,'Policies read and acknowledged',NULL,7),
('b0000000-0000-4000-8000-000000000008','onboarding',NULL,'Trial or probation review booked',NULL,14),
('b0000000-0000-4000-8000-000000000009','offboarding',NULL,'Confirm resignation or termination and last day in writing',NULL,-14),
('b0000000-0000-4000-8000-000000000010','offboarding',NULL,'Exit conversation',NULL,-3),
('b0000000-0000-4000-8000-000000000011','offboarding',NULL,'Return equipment, keys and cards',NULL,0),
('b0000000-0000-4000-8000-000000000012','offboarding',NULL,'Final pay and leave payout to payroll',NULL,0),
('b0000000-0000-4000-8000-000000000013','offboarding',NULL,'Remove system and building access',NULL,0)
ON CONFLICT DO NOTHING;
