#!/usr/bin/env node
// The one CLI for HR for Claude Code. Human tables by default, --json for machines.
// Every change needs --actor and is written to the activity table with before and after.
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { getDb, REPO_ROOT } from './lib/db.mjs';
import { parseCsv } from './lib/csv.mjs';
import { table } from './lib/format.mjs';
import { page, table as htmlTable, writeOut, esc, loadBrand } from './lib/render.mjs';

export const commands=['help','employers','people','person','org','headcount','turnover','leave','away','balances','reviews','trials','certifications','policies','cases','tasks','statements','anniversaries','attention','compliance','activity','weekly-review',
 'add-employer','hire','update','agreement','statement','request-leave','decide-leave','book-review','complete-review','add-cert','add-policy','acknowledge','open-case','case-note','update-case','task','done','terminate','import','export',
 'draft-offer','draft-reminders','draft-service-letter'];
export const TYPES=['full_time','part_time','casual','fixed_term'];
export const LEAVE=['annual','sick','personal','long_service','alternative','bereavement','parental','family_violence','unpaid'];

const today=()=>new Date().toISOString().slice(0,10);
function need(v,k){if(v===undefined||v===null||v===true||String(v).trim()==='')throw Error(`Required: --${k}`);return String(v).trim();}
function num(v,k,{min=null,max=null}={}){const n=Number(String(need(v,k)).replace(/,/g,''));if(!Number.isFinite(n))throw Error(`${k} must be a number`);if(min!==null&&n<min)throw Error(`${k} must be ${min} or more`);if(max!==null&&n>max)throw Error(`${k} must be ${max} or less`);return n;}
export function date(v,k){const s=need(v,k);let m;
 if((m=s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/)))return date(`${m[3]}-${m[2].padStart(2,'0')}-${m[1].padStart(2,'0')}`,k);
 if(!/^\d{4}-\d{2}-\d{2}$/.test(s)||new Date(s+'T00:00:00Z').toISOString().slice(0,10)!==s)throw Error(`${k} must be a real date, YYYY-MM-DD or DD/MM/YYYY`);return s;}
function oneOf(v,k,list){const s=need(v,k).toLowerCase().replace(/[- ]/g,'_');if(!list.includes(s))throw Error(`${k} must be one of: ${list.join(', ')}`);return s;}
function bool(v,k){if(!['true','false'].includes(String(v)))throw Error(`${k} must be true or false`);return String(v)==='true';}
const like=s=>`%${s.toLowerCase().replace(/[%_\\]/g,'\\$&')}%`;
const idLike=s=>/^[0-9a-f-]{4,}$/i.test(s)?s.toLowerCase()+'%':'no-id-match';

const MATCH={
 employer:{flag:'employer',label:r=>`${r.name} (${r.country})`,sql:`SELECT * FROM employers WHERE id::text LIKE $2 OR lower(name)=lower($1) OR lower(name) LIKE $3 OR lower(eh_name)=lower($1) ORDER BY name`,exact:r=>[r.name,r.eh_name]},
 employee:{flag:'employee',label:r=>`${r.code} ${r.first_name} ${r.last_name} (${r.job_title||'no title'})`,
  sql:`SELECT * FROM employees WHERE lower(code)=lower($1) OR id::text LIKE $2 OR lower(first_name||' '||last_name)=lower($1) OR lower(first_name||' '||last_name) LIKE $3 OR lower(coalesce(preferred_name,'')||' '||last_name)=lower($1) OR lower(email)=lower($1) ORDER BY last_name,first_name`,
  exact:r=>[r.code,`${r.first_name} ${r.last_name}`,r.email]},
 policy:{flag:'policy',label:r=>`${r.name} v${r.version}`,sql:`SELECT * FROM policies WHERE id::text LIKE $2 OR lower(name)=lower($1) OR lower(name) LIKE $3 ORDER BY name`,exact:r=>[r.name]},
 case:{flag:'case',label:r=>`${r.id} ${r.kind}: ${r.summary.slice(0,50)}`,sql:`SELECT c.* FROM cases c JOIN employees e ON e.id=c.employee_id WHERE c.id::text LIKE $2 OR (c.closed_on IS NULL AND (lower(e.code)=lower($1) OR lower(e.first_name||' '||e.last_name) LIKE $3)) ORDER BY c.opened_on`,exact:()=>[]},
 leave:{flag:'request',label:r=>`${r.id} ${r.leave_type} ${r.starts_on} to ${r.ends_on} (${r.status})`,sql:`SELECT q.* FROM leave_requests q JOIN employees e ON e.id=q.employee_id WHERE q.id::text LIKE $2 OR (q.status='requested' AND (lower(e.code)=lower($1) OR lower(e.first_name||' '||e.last_name) LIKE $3)) ORDER BY q.starts_on`,exact:()=>[]},
 review:{flag:'review',label:r=>`${r.id} ${r.kind} due ${r.due_on}`,sql:`SELECT r.* FROM reviews r JOIN employees e ON e.id=r.employee_id WHERE r.id::text LIKE $2 OR (r.completed_on IS NULL AND (lower(e.code)=lower($1) OR lower(e.first_name||' '||e.last_name) LIKE $3)) ORDER BY r.due_on`,exact:()=>[]}
};
// An exact code, name or email wins over a partial one, so "Sam" never collides with "Samantha".
export async function match(db,kind,ref){
 const m=MATCH[kind];ref=need(ref,m.flag);
 const rows=await db.query(m.sql,[ref,idLike(ref),like(ref)]);
 const exact=rows.filter(r=>m.exact(r).some(x=>x&&String(x).toLowerCase()===ref.toLowerCase()));
 const hit=exact.length===1?exact:rows;
 if(hit.length!==1)throw Error(hit.length?`Ambiguous ${kind} "${ref}". Use the code, the full name or an id:\n${hit.map(m.label).join('\n')}`:`No ${kind} matches "${ref}"`);
 return hit[0];
}
async function tx(db,fn,dry=false){await db.exec('BEGIN');try{const r=await fn();await db.exec(dry?'ROLLBACK':'COMMIT');return r;}catch(e){await db.exec('ROLLBACK');throw e;}}
async function audit(db,record,id,action,actor,before,after,evidence){await db.query('INSERT INTO activity(record,record_id,action,actor,before_data,after_data,evidence) VALUES($1,$2,$3,$4,$5,$6,$7)',[record,id,action,actor,before?JSON.stringify(before):null,after?JSON.stringify(after):null,evidence??null]);}
async function insert(db,t,row){const k=Object.keys(row);return (await db.query(`INSERT INTO ${t}(${k.join(',')}) VALUES(${k.map((_,i)=>'$'+(i+1)).join(',')}) RETURNING *`,Object.values(row)))[0];}
async function patch(db,t,id,row){const k=Object.keys(row);return (await db.query(`UPDATE ${t} SET ${k.map((x,i)=>`${x}=$${i+1}`).join(',')} WHERE id=$${k.length+1} RETURNING *`,[...Object.values(row),id]))[0];}
async function one(db,sql,p=[]){return (await db.query(sql,p))[0];}

const reads={
 employers:`SELECT s.employer,s.country,r.accredited_employer,s.headcount,s.counted_for_size,CASE WHEN s.country='AU' THEN s.small_business END AS small_business FROM v_employer_size s JOIN employers r ON r.id=s.employer_id ORDER BY s.employer`,
 org:`WITH RECURSIVE t AS (SELECT id,name,job_title,employer,0 AS depth,name::text AS path FROM v_current WHERE manager_id IS NULL
   UNION ALL SELECT p.id,p.name,p.job_title,p.employer,t.depth+1,t.path||' > '||p.name FROM v_current p JOIN t ON p.manager_id=t.id)
   SELECT repeat('  ',depth)||name AS person,job_title,employer,(SELECT count(*) FROM v_current c WHERE c.manager_id=t.id) AS direct_reports FROM t ORDER BY path`,
 headcount:`SELECT * FROM v_headcount ORDER BY employer,department`,
 turnover:`SELECT * FROM v_turnover ORDER BY employer`,
 leave:`SELECT name,employer,manager,leave_type,starts_on,ends_on,hours,requested_on,days_waiting,reason FROM v_leave_open ORDER BY requested_on`,
 away:`SELECT name,employer,department,manager,leave_type,starts_on,ends_on,hours FROM v_away ORDER BY starts_on,name`,
 balances:`SELECT name,employer,leave_type,hours,hours_per_week,weeks,as_at,large FROM v_balances ORDER BY large DESC,employer,name,leave_type`,
 reviews:`SELECT name,employer,manager,kind,due_on,state,reviewer FROM v_reviews ORDER BY due_on`,
 trials:`SELECT name,employer,country,manager,kind,start_date,ends_on,days_left,reviewed FROM v_trials ORDER BY ends_on`,
 certifications:`SELECT name,employer,job_title,certification,expires_on,days_left,state,required FROM v_certs ORDER BY array_position(ARRAY['expired','expiring','current','no expiry'],state),expires_on`,
 policies:`SELECT policy,version,name,employer,manager,applies_from,days_open FROM v_policy_gaps ORDER BY policy,days_open DESC`,
 cases:`SELECT name,employer,kind,opened_on,owner,next_step,next_step_due,days_overdue,last_note FROM v_cases ORDER BY next_step_due NULLS FIRST`,
 tasks:`SELECT name,employer,kind,task,owner,due_on,state FROM v_tasks ORDER BY due_on,name`,
 statements:`SELECT d.name,d.employer,d.kind,d.due_from,(SELECT max(given_on) FROM statements s WHERE s.employee_id=d.employee_id AND s.kind=d.kind) AS last_given FROM v_statements_due d ORDER BY d.name,d.kind`,
 anniversaries:`SELECT name,employer,department,manager,anniversary,years FROM v_anniversaries ORDER BY anniversary`,
 attention:`SELECT item,issue,detail FROM v_attention ORDER BY issue,item`,
 compliance:`SELECT rule,item,finding FROM v_compliance ORDER BY rule,item`,
 activity:`SELECT created_at,record,action,actor,evidence FROM activity ORDER BY created_at DESC,id DESC LIMIT 100`
};

// ---------------------------------------------------------------- imports
// Employment Hero: People > Import Employees > Advanced Import Employees, with "Include existing user
// information" (and "Include terminated users") ticked, downloads a template filled with every employee.
// Column names vary by region and plan, so each field accepts the common headers, and a map file can name others.
const COLS={
 code:['Employee Code','Employee ID','Employee Number','Employee No','Payroll ID'],first:['First Name','Legal First Name'],last:['Last Name','Surname'],preferred:['Known As','Preferred Name'],
 email:['Work Email','Email','Personal Email'],phone:['Mobile','Mobile Number','Phone','Phone Number'],title:['Job Title','Position','Position Title'],department:['Department','Team'],
 location:['Location','Work Location','Primary Location'],manager:['Primary Manager','Manager','Primary Manager Email','Manager Email','Reports To'],type:['Employment Type','Employment Status'],
 hours:['Hours Per Week','Work Hours Per Week','Ordinary Hours','Standard Hours'],start:['Start Date','Employment Start Date','Commencement Date'],fixed_end:['Contract End Date','Fixed Term End Date','End Date'],
 termination:['Termination Date','Terminated Date'],dob:['Date of Birth','DOB'],employer:['Organisation','Organisation Name','Company','Business','Business Name']
};
function readMap(o){return o.map?JSON.parse(fs.readFileSync(path.resolve(o.map),'utf8')):{};}
function col(row,map,field){const want=[map.columns?.[field],...COLS[field]].filter(Boolean);for(const w of want){const k=Object.keys(row).find(h=>h.trim().toLowerCase()===w.toLowerCase());if(k!==undefined){const v=String(row[k]??'').trim();return v===''?null:v;}}return null;}
export function employmentType(v,where){const s=String(v||'').toLowerCase();
 if(/casual/.test(s))return 'casual';if(/fixed|contract|temp/.test(s))return 'fixed_term';if(/part/.test(s))return 'part_time';if(/full|permanent/.test(s))return 'full_time';
 throw Error(`${where}: employment type "${v}" is not full time, part time, casual or fixed term (name it in the map file under "types")`);}
async function importEmployees(db,o,actor){
 const filename=path.resolve(need(o.file,'file'));const input=fs.readFileSync(filename,'utf8');const rows=parseCsv(input);if(!rows.length)throw Error('No data rows');
 const map=readMap(o);const headers=Object.keys(rows[0]);
 for(const f of ['code','first','last','start'])if(!headers.some(h=>[map.columns?.[f],...COLS[f]].filter(Boolean).some(w=>w.toLowerCase()===h.trim().toLowerCase())))throw Error(`No ${COLS[f][0]} column. Is this the Employment Hero employee template? Columns found: ${headers.join(', ')}`);
 const employers=await db.query('SELECT * FROM employers');const fixed=o.employer?await match(db,'employer',o.employer):null;
 const findEmployer=v=>{if(fixed)return fixed;const t=map.employers?.[v]??v;return employers.find(r=>[r.name,r.eh_name].some(x=>x&&t&&x.toLowerCase()===t.toLowerCase()))||(employers.length===1?employers[0]:null);};
 const parsed=[],problems=[];
 rows.forEach((row,i)=>{const where=`Row ${i+2}`;try{
  const emp=findEmployer(col(row,map,'employer'));if(!emp)throw Error(`no employer matches "${col(row,map,'employer')||''}" (pass --employer or add it to the map file)`);
  const rawType=col(row,map,'type');const type=map.types?.[rawType]??employmentType(rawType,where);
  const rec={employer_id:emp.id,code:need(col(row,map,'code'),'Employee Code'),first_name:need(col(row,map,'first'),'First Name'),last_name:need(col(row,map,'last'),'Last Name'),
   preferred_name:col(row,map,'preferred'),email:col(row,map,'email'),phone:col(row,map,'phone'),job_title:col(row,map,'title'),department:col(row,map,'department'),location:col(row,map,'location'),
   employment_type:type,hours_per_week:col(row,map,'hours')?num(col(row,map,'hours'),'hours'):null,start_date:date(col(row,map,'start'),'Start Date'),
   fixed_term_end:col(row,map,'fixed_end')&&type==='fixed_term'?date(col(row,map,'fixed_end'),'Contract End Date'):null,
   termination_date:col(row,map,'termination')?date(col(row,map,'termination'),'Termination Date'):null,date_of_birth:col(row,map,'dob')?date(col(row,map,'dob'),'Date of Birth'):null,
   source:JSON.stringify({file:path.basename(filename),row:i+2})};
  if(type==='fixed_term'&&!rec.fixed_term_end)throw Error('fixed-term employee with no contract end date');
  parsed.push({rec,manager:col(row,map,'manager'),where});
 }catch(e){problems.push(`${where}: ${e.message}`);}});
 if(problems.length)throw Error(`Nothing imported. Fix these rows (docs/replace-employment-hero.md):\n${problems.slice(0,20).join('\n')}`);
 const seen=new Set();for(const p of parsed){if(seen.has(p.rec.code.toLowerCase()))throw Error(`${p.where}: employee code ${p.rec.code} appears twice in the file`);seen.add(p.rec.code.toLowerCase());}
 return tx(db,async()=>{
  let inserted=0,updated=0,unchanged=0;const changed=[];const KEYS=['first_name','last_name','preferred_name','email','phone','job_title','department','location','employment_type','hours_per_week','start_date','fixed_term_end','termination_date','date_of_birth'];
  for(const p of parsed){const old=await one(db,'SELECT * FROM employees WHERE lower(code)=lower($1)',[p.rec.code]);
   if(!old){const r=await insert(db,'employees',p.rec);await audit(db,'employees',r.id,'import employment-hero',actor,null,r,path.basename(filename));inserted++;continue;}
   const norm=v=>v instanceof Date?v.toISOString().slice(0,10):v===null||v===undefined?null:String(v);
   const diff=KEYS.filter(k=>norm(old[k])!==norm(p.rec[k])&&!(p.rec[k]===null&&old[k]!==null));
   if(!diff.length){unchanged++;continue;}
   if(!o.update){changed.push(`${p.rec.code} ${p.rec.first_name} ${p.rec.last_name}: ${diff.map(k=>`${k} ${norm(old[k])} -> ${norm(p.rec[k])}`).join(', ')}`);continue;}
   const r=await patch(db,'employees',old.id,Object.fromEntries(diff.map(k=>[k,p.rec[k]])));await audit(db,'employees',old.id,'import employment-hero',actor,old,r,path.basename(filename));updated++;}
  if(changed.length)throw Error(`${changed.length} employee(s) differ from what is on file. Review them, then re-run with --update:\n${changed.slice(0,10).join('\n')}`);
  // Managers second, so a manager later in the file still matches.
  let managers=0;const missing=[];
  for(const p of parsed){if(!p.manager)continue;const mgr=await one(db,`SELECT id FROM employees WHERE lower(code)=lower($1) OR lower(email)=lower($1) OR lower(first_name||' '||last_name)=lower($1)`,[p.manager]);
   if(!mgr){missing.push(`${p.rec.code}: manager "${p.manager}"`);continue;}
   const e=await one(db,'SELECT * FROM employees WHERE lower(code)=lower($1)',[p.rec.code]);if(e.manager_id!==mgr.id&&e.id!==mgr.id){await patch(db,'employees',e.id,{manager_id:mgr.id});managers++;}}
  await db.query('INSERT INTO imports(filename,sha256,kind,row_count,actor) VALUES($1,$2,$3,$4,$5)',[path.basename(filename),createHash('sha256').update(input).digest('hex'),'employment-hero',parsed.length,actor]);
  return {employees:parsed.length,inserted,updated,unchanged,managers_linked:managers,managers_not_found:missing,dry_run:Boolean(o['dry-run'])};
 },Boolean(o['dry-run']));
}
// Leave balances from payroll (Employment Hero, KeyPay, Xero, MYOB): Employee Code, Leave Type, Balance in hours, As At.
export function leaveType(v,where){const s=String(v||'').toLowerCase();
 if(/long/.test(s))return 'long_service';if(/annual|holiday pay|annual holiday/.test(s))return 'annual';if(/alternat|lieu/.test(s))return 'alternative';if(/sick/.test(s))return 'sick';if(/personal|carer/.test(s))return 'personal';
 throw Error(`${where}: leave type "${v}" is not annual, sick, personal, long service or alternative`);}
async function importBalances(db,o,actor){
 const filename=path.resolve(need(o.file,'file'));const input=fs.readFileSync(filename,'utf8');const rows=parseCsv(input);if(!rows.length)throw Error('No data rows');
 const get=(row,...names)=>{for(const n of names){const k=Object.keys(row).find(h=>h.trim().toLowerCase()===n.toLowerCase());if(k!==undefined&&String(row[k]).trim()!=='')return String(row[k]).trim();}return null;};
 const values=[],problems=[];
 for(const [i,row] of rows.entries()){const where=`Row ${i+2}`;try{
  const code=need(get(row,'Employee Code','Employee ID','Employee Number'),'Employee Code');const e=await one(db,'SELECT id FROM employees WHERE lower(code)=lower($1)',[code]);if(!e)throw Error(`no employee with code ${code}`);
  const asAt=o['as-at']?date(o['as-at'],'as-at'):date(get(row,'As At','As At Date','Date'),'As At');
  values.push({employee_id:e.id,leave_type:leaveType(get(row,'Leave Type','Leave Category','Category'),where),hours:num(get(row,'Balance','Balance (Hours)','Hours','Available Balance'),'Balance'),as_at:asAt});
 }catch(e){problems.push(`${where}: ${e.message}`);}}
 if(problems.length)throw Error(`Nothing imported:\n${problems.slice(0,20).join('\n')}`);
 return tx(db,async()=>{for(const v of values)await db.query(`INSERT INTO leave_balances(employee_id,leave_type,hours,as_at) VALUES($1,$2,$3,$4) ON CONFLICT(employee_id,leave_type) DO UPDATE SET hours=excluded.hours,as_at=excluded.as_at`,[v.employee_id,v.leave_type,v.hours,v.as_at]);
  await db.query('INSERT INTO imports(filename,sha256,kind,row_count,actor) VALUES($1,$2,$3,$4,$5)',[path.basename(filename),createHash('sha256').update(input).digest('hex'),'balances',values.length,actor]);
  await audit(db,'leave_balances',null,'import balances',actor,null,{rows:values.length},path.basename(filename));return {balances:values.length,dry_run:Boolean(o['dry-run'])};},Boolean(o['dry-run']));
}

// ---------------------------------------------------------------- drafts
const slug=s=>String(s).toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
function draftFile(name,html){return writeOut('drafts',`${name}-${Date.now()}`,html);}
const fullName=e=>`${e.first_name} ${e.last_name}`;
const TYPE_WORDS={full_time:'full time',part_time:'part time',casual:'casual',fixed_term:'fixed term'};

async function person(db,o){const e=await match(db,'employee',o.employee);const id=e.id;
 return {
  employee:await db.query('SELECT code,name,known_as,employer,country,job_title,department,location,manager,email,employment_type,hours_per_week,start_date,fixed_term_end,trial_period_days,probation_end,work_rights,visa_type,visa_expires_on,status,months_served,termination_date,termination_reason FROM v_people WHERE id=$1',[id]),
  agreements:await db.query('SELECT kind,offered_on,signed_on,starts_on,ends_on,summary,evidence FROM agreements WHERE employee_id=$1 ORDER BY coalesce(signed_on,offered_on)',[id]),
  statements:await db.query('SELECT kind,given_on,evidence FROM statements WHERE employee_id=$1 ORDER BY given_on',[id]),
  leave_balances:await db.query('SELECT leave_type,hours,as_at FROM leave_balances WHERE employee_id=$1 ORDER BY leave_type',[id]),
  leave:await db.query('SELECT leave_type,starts_on,ends_on,hours,status,decided_by FROM leave_requests WHERE employee_id=$1 ORDER BY starts_on DESC LIMIT 10',[id]),
  reviews:await db.query('SELECT kind,due_on,completed_on,reviewer,outcome FROM reviews WHERE employee_id=$1 ORDER BY due_on DESC',[id]),
  certifications:await db.query('SELECT certification,expires_on,state,required FROM v_certs WHERE employee_id=$1',[id]),
  policies_outstanding:await db.query('SELECT policy,version,days_open FROM v_policy_gaps WHERE employee_id=$1',[id]),
  cases:await db.query('SELECT kind,opened_on,owner,summary,next_step,next_step_due,closed_on,outcome FROM cases WHERE employee_id=$1 ORDER BY opened_on DESC',[id]),
  tasks:await db.query('SELECT kind,task,owner,due_on,done_on FROM tasks WHERE employee_id=$1 ORDER BY due_on',[id]),
  checks:await db.query(`SELECT rule,finding FROM v_compliance WHERE item LIKE $1 ORDER BY rule`,[`${fullName(e)} (%`])
 };}

export async function run(db,cmd,o={},args=[]){
 if(!commands.includes(cmd))throw Error(`Unknown command "${cmd}". Run help for the list`);
 if(cmd==='help')return commands.map(command=>({command}));
 if(reads[cmd])return db.query(reads[cmd]);
 if(cmd==='people'){const conds=[],p=[];const st=o.status?oneOf(o.status,'status',['active','leaving','starting','left','all']):null;
  if(!st)conds.push(`status IN ('active','leaving','starting')`);else if(st!=='all'){p.push(st);conds.push(`status=$${p.length}`);}
  if(o.employer){const r=await match(db,'employer',o.employer);p.push(r.id);conds.push(`employer_id=$${p.length}`);}
  if(o.department){p.push(o.department);conds.push(`lower(department)=lower($${p.length})`);}
  if(o.type){p.push(oneOf(o.type,'type',TYPES));conds.push(`employment_type=$${p.length}`);}
  return db.query(`SELECT code,name,employer,job_title,department,manager,employment_type,hours_per_week,start_date,status FROM v_people${conds.length?' WHERE '+conds.join(' AND '):''} ORDER BY employer,name`,p);}
 if(cmd==='person')return person(db,o);
 if(cmd==='weekly-review')return {attention:await run(db,'attention'),compliance:await run(db,'compliance'),away:await run(db,'away'),reviews_due:(await run(db,'reviews')).filter(r=>r.state!=='booked'),trials:(await run(db,'trials')).filter(r=>r.days_left<=30)};
 if(cmd==='export'){
  const dir=path.resolve(o.out||path.join(REPO_ROOT,'exports',new Date().toISOString().replace(/[:.]/g,'-')));fs.mkdirSync(dir,{recursive:true});const out=[];
  for(const t of ['employers','employees','agreements','statements','leave_balances','leave_requests','policies','acknowledgements','reviews','certifications','cases','case_notes','tasks','task_templates','settings','activity','imports']){const file=path.join(dir,t+'.json');if(fs.existsSync(file))throw Error(`Export already exists: ${file}`);const rows=await db.query(`SELECT * FROM ${t} ORDER BY 1`);fs.writeFileSync(file,JSON.stringify(rows,null,2)+'\n');out.push({records:t,count:rows.length,file});}
  return out;}
 if(cmd==='draft-offer'){const e=await match(db,'employee',o.employee);const p=await one(db,'SELECT * FROM v_people WHERE id=$1',[e.id]);const brand=loadBrand();
  const trial=p.country==='NZ'&&p.trial_period_days?`<p>This offer includes a trial period of ${p.trial_period_days} days from your start date. It only applies if you sign the employment agreement before you start work.</p>`:'';
  const prob=p.probation_end?`<p>Your employment includes a probation period ending ${esc(p.probation_end)}.</p>`:'';
  const au=p.country==='AU'?`<p>With this letter you will receive the Fair Work Information Statement${p.employment_type==='casual'?' and the Casual Employment Information Statement':''}${p.employment_type==='fixed_term'?' and the Fixed Term Contract Information Statement':''}.</p>`:'';
  const file=draftFile(`offer-${slug(p.name)}`,page({title:`Offer of employment: ${p.name}`,subtitle:'DRAFT for the hiring manager to check against the employment agreement. Nothing has been sent.',sections:[
   {title:'Letter',html:`<p>Dear ${esc(p.known_as)},</p><p>We are pleased to offer you the ${esc(TYPE_WORDS[p.employment_type])} role of ${esc(p.job_title||'(role)')} with ${esc(p.employer)}, reporting to ${esc(p.manager||'(manager)')}, starting ${esc(p.start_date)}${p.hours_per_week?`, ${esc(p.hours_per_week)} hours a week`:''}${p.fixed_term_end?`, for a fixed term ending ${esc(p.fixed_term_end)}`:''}.</p>${trial}${prob}${au}<p>The full terms are in the employment agreement attached. Please read it, take advice if you wish, and sign and return it before your first day.</p><p>Kind regards,<br>${esc(o.from||'(name)')}<br>${esc(brand.business_name)}</p>`}]}));
  return {file,employee:p.name};}
 if(cmd==='draft-reminders'){const rows=[...(await db.query(`SELECT employee_id,'Acknowledge the '||policy||' (version '||version||')' AS item FROM v_policy_gaps WHERE days_open>=setting('ack_days')`)),
   ...(await db.query(`SELECT employee_id,'Renew your '||certification||' (expires '||expires_on||')' AS item FROM v_certs WHERE state IN ('expired','expiring') AND required`)),
   ...(await db.query(`SELECT id AS employee_id,'Send us your new visa: the current one '||CASE WHEN visa_expires_on<current_date THEN 'expired ' ELSE 'expires ' END||visa_expires_on AS item FROM v_people WHERE work_rights='visa' AND status IN ('active','leaving','starting') AND visa_expires_on<=current_date+setting('visa_warning_days')::int`))];
  if(!rows.length)throw Error('Nothing to remind anyone about');
  const by={};for(const r of rows)(by[r.employee_id]||=[]).push(r.item);const files=[];
  for(const [id,items] of Object.entries(by)){const e=await one(db,'SELECT * FROM employees WHERE id=$1',[id]);
   const body=`To: ${e.email||'(no email on file)'}\nSubject: A couple of things we need from you\n\nHi ${e.preferred_name||e.first_name},\n\nOur records show these are outstanding:\n\n${items.map(i=>`- ${i}`).join('\n')}\n\nCould you sort these out this week, or let me know if our records are wrong?\n\nThanks.\n\nDRAFT. Not sent. Edit before sending.\n`;
   const file=path.join(path.resolve(process.env.OUTPUT_DIR||REPO_ROOT,'drafts'),`reminder-${slug(fullName(e))}-${Date.now()}.txt`);fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,body);files.push({file,to:e.email,items:items.length});}
  return files;}
 if(cmd==='draft-service-letter'){const e=await match(db,'employee',o.employee);const p=await one(db,'SELECT * FROM v_people WHERE id=$1',[e.id]);
  if(!p.termination_date)throw Error(`${p.name} has no termination date. Record it with terminate first`);
  const file=draftFile(`service-letter-${slug(p.name)}`,page({title:`Certificate of service: ${p.name}`,subtitle:'DRAFT. Check the dates and role against the employee file before signing. Nothing has been sent.',sections:[
   {title:'To whom it may concern',html:`<p>${esc(p.name)} was employed by ${esc(p.employer)} from ${esc(p.start_date)} to ${esc(p.termination_date)}, most recently as ${esc(p.job_title||'(role)')} (${esc(TYPE_WORDS[p.employment_type])}).</p><p>Signed: ____________________&nbsp;&nbsp;&nbsp;Date: __________</p>`}]}));
  return {file,employee:p.name};}

 const actor=need(o.actor,'actor');
 if(cmd==='import'){if(args[0]==='employment-hero')return importEmployees(db,o,actor);if(args[0]==='balances')return importBalances(db,o,actor);throw Error('Import supports: import employment-hero --file=... [--employer=...] [--map=...] | import balances --file=...');}
 return tx(db,async()=>{
  if(cmd==='add-employer'){const country=need(o.country,'country').toUpperCase();if(!['NZ','AU'].includes(country))throw Error('country must be NZ or AU');
   const row={name:need(o.name,'name'),country};if(o.accredited!==undefined)row.accredited_employer=bool(o.accredited,'accredited');if(o['eh-name'])row.eh_name=need(o['eh-name'],'eh-name');
   const r=await insert(db,'employers',row);await audit(db,'employers',r.id,cmd,actor,null,r,'manual entry');return r;}
  if(cmd==='hire'){const emp=await match(db,'employer',o.employer);const row={employer_id:emp.id,code:need(o.code,'code'),first_name:need(o.first,'first'),last_name:need(o.last,'last'),
    employment_type:oneOf(o.type,'type',TYPES),start_date:date(o.start,'start')};
   for(const [f,c] of [['email','email'],['title','job_title'],['department','department'],['location','location'],['preferred','preferred_name'],['visa-type','visa_type']])if(o[f]!==undefined)row[c]=need(o[f],f);
   if(o.hours!==undefined)row.hours_per_week=num(o.hours,'hours',{min:1,max:80});if(o.manager)row.manager_id=(await match(db,'employee',o.manager)).id;
   if(o['fixed-end'])row.fixed_term_end=date(o['fixed-end'],'fixed-end');if(row.employment_type==='fixed_term'&&!row.fixed_term_end)throw Error('A fixed-term hire needs --fixed-end=YYYY-MM-DD');
   if(o.trial!==undefined){if(emp.country!=='NZ')throw Error('Trial periods under s67A are NZ only. Use --probation-end for Australia');row.trial_period_days=num(o.trial,'trial',{min:1,max:90});}
   if(o['probation-end'])row.probation_end=date(o['probation-end'],'probation-end');
   if(o['work-rights'])row.work_rights=oneOf(o['work-rights'],'work-rights',['citizen','resident','visa']);if(o['visa-expires'])row.visa_expires_on=date(o['visa-expires'],'visa-expires');
   if(row.work_rights==='visa'&&!row.visa_expires_on)throw Error('A visa holder needs --visa-expires=YYYY-MM-DD (check it with Immigration NZ VisaView or VEVO)');
   const r=await insert(db,'employees',row);await audit(db,'employees',r.id,cmd,actor,null,r,o.evidence||'new hire');
   const tpl=await db.query(`SELECT * FROM task_templates WHERE kind='onboarding' AND (country IS NULL OR country=$1) ORDER BY days_from,task`,[emp.country]);
   for(const t of tpl)await insert(db,'tasks',{employee_id:r.id,kind:'onboarding',task:t.task,owner:t.owner||o.owner||null,due_on:new Date(Date.parse(row.start_date)+t.days_from*86400000).toISOString().slice(0,10)});
   return {...r,onboarding_tasks:tpl.length};}
  if(cmd==='update'){const e=await match(db,'employee',o.employee);const row={};
   for(const [f,c] of [['email','email'],['title','job_title'],['department','department'],['location','location'],['preferred','preferred_name'],['visa-type','visa_type'],['phone','phone'],['fixed-term-exception','fixed_term_exception']])if(o[f]!==undefined)row[c]=o[f]==='null'?null:need(o[f],f);
   if(o.type)row.employment_type=oneOf(o.type,'type',TYPES);if(o.hours!==undefined)row.hours_per_week=num(o.hours,'hours',{min:1,max:80});
   if(o.manager)row.manager_id=o.manager==='null'?null:(await match(db,'employee',o.manager)).id;
   for(const [f,c] of [['fixed-end','fixed_term_end'],['probation-end','probation_end'],['visa-expires','visa_expires_on'],['start','start_date']])if(o[f]!==undefined)row[c]=o[f]==='null'?null:date(o[f],f);
   if(o['work-rights'])row.work_rights=oneOf(o['work-rights'],'work-rights',['citizen','resident','visa']);if(o.trial!==undefined)row.trial_period_days=o.trial==='null'?null:num(o.trial,'trial',{min:1,max:90});
   if(!Object.keys(row).length)throw Error('No fields to change');const r=await patch(db,'employees',e.id,row);await audit(db,'employees',e.id,cmd,actor,e,r,need(o.evidence,'evidence'));return r;}
  if(cmd==='agreement'){const e=await match(db,'employee',o.employee);const row={employee_id:e.id,kind:o.kind?oneOf(o.kind,'kind',['employment_agreement','variation','fixed_term_renewal']):'employment_agreement',evidence:need(o.evidence,'evidence')};
   for(const [f,c] of [['offered','offered_on'],['signed','signed_on'],['starts','starts_on'],['ends','ends_on']])if(o[f])row[c]=date(o[f],f);if(o.summary)row.summary=need(o.summary,'summary');
   if(row.signed_on&&row.signed_on>today())throw Error('signed cannot be in the future');
   const r=await insert(db,'agreements',row);await audit(db,'agreements',r.id,cmd,actor,null,r,r.evidence);return r;}
  if(cmd==='statement'){const e=await match(db,'employee',o.employee);const emp=await one(db,'SELECT country FROM employers WHERE id=$1',[e.employer_id]);if(emp.country!=='AU')throw Error('Information statements are an Australian requirement');
   const kind=need(o.kind,'kind').toUpperCase();if(!['FWIS','CEIS','FTCIS'].includes(kind))throw Error('kind must be FWIS, CEIS or FTCIS');
   const r=await insert(db,'statements',{employee_id:e.id,kind,given_on:o.date?date(o.date,'date'):today(),evidence:need(o.evidence,'evidence')});await audit(db,'statements',r.id,cmd,actor,null,r,r.evidence);return r;}
  if(cmd==='request-leave'){const e=await match(db,'employee',o.employee);const row={employee_id:e.id,leave_type:oneOf(o.type,'type',LEAVE),starts_on:date(o.from,'from'),ends_on:date(o.to??o.from,'to')};
   if(o.hours!==undefined)row.hours=num(o.hours,'hours',{min:0.25});if(o.reason)row.reason=need(o.reason,'reason');if(o.requested)row.requested_on=date(o.requested,'requested');
   const clash=await db.query(`SELECT starts_on,ends_on,status FROM leave_requests WHERE employee_id=$1 AND status IN ('requested','approved') AND starts_on<=$3 AND ends_on>=$2`,[e.id,row.starts_on,row.ends_on]);
   if(clash.length)throw Error(`${fullName(e)} already has leave ${clash[0].status} from ${clash[0].starts_on} to ${clash[0].ends_on}`);
   const r=await insert(db,'leave_requests',row);await audit(db,'leave_requests',r.id,cmd,actor,null,r,o.evidence||'leave request');return r;}
  if(cmd==='decide-leave'){const q=await match(db,'leave',o.request);if(q.status!=='requested')throw Error(`That request is already ${q.status}`);
   const r=await patch(db,'leave_requests',q.id,{status:oneOf(o.decision,'decision',['approved','declined']),decided_by:need(o.by??actor,'by'),decided_on:o.date?date(o.date,'date'):today(),decision_note:o.note||null});
   await audit(db,'leave_requests',q.id,cmd,actor,q,r,o.note||r.status);return r;}
  if(cmd==='book-review'){const e=await match(db,'employee',o.employee);const r=await insert(db,'reviews',{employee_id:e.id,kind:oneOf(o.kind,'kind',['trial','probation','annual','one_on_one']),due_on:date(o.due,'due'),reviewer:o.reviewer?need(o.reviewer,'reviewer'):null});
   await audit(db,'reviews',r.id,cmd,actor,null,r,'review booked');return r;}
  if(cmd==='complete-review'){const v=await match(db,'review',o.review);if(v.completed_on)throw Error(`Already completed on ${v.completed_on}`);
   const r=await patch(db,'reviews',v.id,{completed_on:o.date?date(o.date,'date'):today(),outcome:need(o.outcome,'outcome'),notes:o.notes||null,reviewer:o.reviewer||v.reviewer});
   await audit(db,'reviews',v.id,cmd,actor,v,r,r.outcome);let next=null;
   if(v.kind==='annual'&&!o['no-next']){const cyc=Number((await one(db,`SELECT setting('review_cycle_months') AS m`)).m);const d=new Date(r.completed_on);d.setUTCMonth(d.getUTCMonth()+cyc);
    next=await insert(db,'reviews',{employee_id:v.employee_id,kind:'annual',due_on:d.toISOString().slice(0,10),reviewer:r.reviewer});}
   return {...r,next_review:next?.due_on??null};}
  if(cmd==='add-cert'){const e=await match(db,'employee',o.employee);const row={employee_id:e.id,name:need(o.name,'name'),evidence:need(o.evidence,'evidence')};
   if(o.issued)row.issued_on=date(o.issued,'issued');if(o.expires)row.expires_on=date(o.expires,'expires');if(o.required!==undefined)row.required=bool(o.required,'required');
   const r=await insert(db,'certifications',row);await audit(db,'certifications',r.id,cmd,actor,null,r,r.evidence);return r;}
  if(cmd==='add-policy'){const name=need(o.name,'name');const old=await one(db,'SELECT * FROM policies WHERE lower(name)=lower($1)',[name]);
   const row={version:need(o.version,'version'),effective_on:o.effective?date(o.effective,'effective'):today()};if(o.link)row.link=need(o.link,'link');if(o['applies-to'])row.applies_to=o['applies-to'].toUpperCase()==='ALL'?'all':oneOf(o['applies-to'].toUpperCase(),'applies-to',['nz','au']).toUpperCase();
   if(o['requires-ack']!==undefined)row.requires_ack=bool(o['requires-ack'],'requires-ack');
   if(old&&old.version===row.version)throw Error(`${old.name} is already at version ${old.version}`);
   const r=old?await patch(db,'policies',old.id,row):await insert(db,'policies',{name,...row});await audit(db,'policies',r.id,cmd,actor,old,r,o.evidence||'policy issued');return r;}
  if(cmd==='acknowledge'){const e=await match(db,'employee',o.employee),pol=await match(db,'policy',o.policy);
   const r=await insert(db,'acknowledgements',{employee_id:e.id,policy_id:pol.id,version:pol.version,acknowledged_on:o.date?date(o.date,'date'):today()});await audit(db,'acknowledgements',r.id,cmd,actor,null,r,o.evidence||'acknowledged');return r;}
  if(cmd==='open-case'){const e=await match(db,'employee',o.employee);const row={employee_id:e.id,kind:oneOf(o.kind,'kind',['performance','misconduct','grievance','wellbeing','other']),owner:need(o.owner,'owner'),summary:need(o.summary,'summary')};
   if(o['next-step'])row.next_step=need(o['next-step'],'next-step');if(o.due)row.next_step_due=date(o.due,'due');if(o.opened)row.opened_on=date(o.opened,'opened');
   const r=await insert(db,'cases',row);await audit(db,'cases',r.id,cmd,actor,null,{id:r.id,kind:r.kind},'case opened');return r;}
  if(cmd==='case-note'){const c=await match(db,'case',o.case);const r=await insert(db,'case_notes',{case_id:c.id,note:need(o.note,'note'),actor,noted_on:o.date?date(o.date,'date'):today()});
   await audit(db,'case_notes',r.id,cmd,actor,null,{case_id:c.id},'note added');return r;}
  if(cmd==='update-case'){const c=await match(db,'case',o.case);if(c.closed_on)throw Error(`Case closed on ${c.closed_on}`);const row={};
   if(o['next-step'])row.next_step=need(o['next-step'],'next-step');if(o.due)row.next_step_due=date(o.due,'due');if(o.owner)row.owner=need(o.owner,'owner');
   if(o.close){row.closed_on=o.date?date(o.date,'date'):today();row.outcome=need(o.outcome,'outcome');}
   if(!Object.keys(row).length)throw Error('No fields to change');const r=await patch(db,'cases',c.id,row);await audit(db,'cases',c.id,cmd,actor,{next_step:c.next_step,next_step_due:c.next_step_due},row,o.outcome||'case updated');return r;}
  if(cmd==='task'){const e=await match(db,'employee',o.employee);const r=await insert(db,'tasks',{employee_id:e.id,kind:o.kind?oneOf(o.kind,'kind',['onboarding','offboarding','other']):'other',task:need(o.task,'task'),owner:o.owner||null,due_on:date(o.due,'due')});
   await audit(db,'tasks',r.id,cmd,actor,null,r,'task added');return r;}
  if(cmd==='done'){const ref=need(o.task,'task');const e=o.employee?await match(db,'employee',o.employee):null;
   const rows=await db.query(`SELECT t.* FROM tasks t WHERE t.done_on IS NULL AND (t.id::text LIKE $1 OR lower(t.task)=lower($2) OR lower(t.task) LIKE $3)${e?' AND t.employee_id=$4':''} ORDER BY t.due_on`,[idLike(ref),ref,like(ref),...(e?[e.id]:[])]);
   if(rows.length!==1)throw Error(rows.length?`More than one open task matches "${ref}". Add --employee or use an id:\n${rows.map(t=>`${t.id} ${t.task} (due ${t.due_on})`).join('\n')}`:`No open task matches "${ref}"`);
   const r=await patch(db,'tasks',rows[0].id,{done_on:o.date?date(o.date,'date'):today(),evidence:need(o.evidence,'evidence')});await audit(db,'tasks',r.id,cmd,actor,rows[0],r,r.evidence);return r;}
  if(cmd==='terminate'){const e=await match(db,'employee',o.employee);if(e.termination_date)throw Error(`${fullName(e)} already has a last day of ${e.termination_date}`);
   const last=date(o['last-day'],'last-day');const r=await patch(db,'employees',e.id,{termination_date:last,termination_reason:need(o.reason,'reason')});await audit(db,'employees',e.id,cmd,actor,e,r,need(o.evidence,'evidence'));
   const tpl=await db.query(`SELECT * FROM task_templates WHERE kind='offboarding' ORDER BY days_from,task`);
   for(const t of tpl)await insert(db,'tasks',{employee_id:e.id,kind:'offboarding',task:t.task,owner:t.owner||o.owner||null,due_on:new Date(Date.parse(last)+t.days_from*86400000).toISOString().slice(0,10)});
   return {employee:fullName(e),last_day:last,offboarding_tasks:tpl.length};}
  throw Error(`Unsupported command ${cmd}`);
 });
}

const FLAGS=new Set(['json','actor','employer','employee','status','department','type','name','country','accredited','eh-name','code','first','last','start','email','title','location','preferred','visa-type','hours','manager','fixed-end','trial','probation-end','work-rights','visa-expires','owner','evidence','phone','fixed-term-exception',
 'kind','offered','signed','starts','ends','summary','date','from','to','reason','requested','request','decision','by','note','due','reviewer','review','outcome','notes','no-next','issued','expires','required','version','effective','link','applies-to','requires-ack','policy','opened','next-step','case','close','task','last-day','file','map','dry-run','update','out','as-at']);
const BOOL=new Set(['json','dry-run','update','close','no-next']);
export function parse(argv){const args=[],o={};for(let i=0;i<argv.length;i++){const a=argv[i];if(!a.startsWith('--')){args.push(a);continue;}
 const eq=a.indexOf('=');const k=eq<0?a.slice(2):a.slice(2,eq);if(!FLAGS.has(k))throw Error(`Unknown flag --${k}`);
 if(BOOL.has(k)){if(eq>=0)throw Error(`--${k} takes no value`);o[k]=true;continue;}
 const v=eq>=0?a.slice(eq+1):argv[++i];if(v===undefined||(eq<0&&v.startsWith('--')))throw Error(`Missing value for --${k}`);o[k]=v;}
 return {cmd:args.shift()||'help',args,o};}
function cell(v){if(v instanceof Date)return v.toISOString().slice(0,10);if(v&&typeof v==='object')return JSON.stringify(v);return v;}
function display(result){
 if(Array.isArray(result))return result.length?table(result,Object.keys(result[0]).map(key=>({key,label:key,width:70,format:v=>cell(v)}))):'(none)';
 return Object.entries(result).map(([k,v])=>Array.isArray(v)?`\n${k.replace(/_/g,' ')}\n${display(v)}`:v&&typeof v==='object'&&!(v instanceof Date)?`\n${k}\n${display([v])}`:`${k}: ${cell(v)}`).join('\n').trim();
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){let db;try{const {cmd,args,o}=parse(process.argv.slice(2));db=await getDb();const r=await run(db,cmd,o,args);console.log(o.json?JSON.stringify(r,null,2):display(r));}catch(e){console.error(e.message);process.exitCode=1;}finally{if(db)await db.close();}}
