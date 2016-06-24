-- Get the List of all Non-Test Bundles
create temporary table login_bundles as
select distinct aa.bundleid
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
join authdb_applications aa
on ecs.applicationid = aa.applicationid
where te.applicationid is null
;

-- Classify Bundles
drop table if exists dashboard.kpi_login_bundle_reg_type
;

create table dashboard.kpi_login_bundle_reg_type as
select lower(a.bundleid) as bundle_id
     , count(*) as eventcnt
     , count(case when b.canregister = true then 1 else null end) as openeventcnt
     , count(case when b.canregister = false then 1 else null end) as closedeventcnt
     , case
         when count(case when b.canregister = true then 1 else null end) > 0 and count(case when b.canregister = false then 1 else null end) = 0 then 'open'
         when count(case when b.canregister = false then 1 else null end) > 0 and count(case when b.canregister = true then 1 else null end) = 0 then 'closed'
         else 'mixed'
       end as bundle_type
     , min(b.startdate) as firsteventsstartdate
     , max(b.startdate) as lasteventstartdate
     , min(b.enddate) as firsteventenddate
     , max(b.enddate) as lasteventenddate
from login_bundles a
join authdb_applications b
on a.bundleid = b.bundleid
group by 1
;

-- Insert New Checkpoint Metrics into STG Table
insert into dashboard.kpi_login_checkpoint_metrics_STG (
  select a.*
  from fact_checkpoints_live a
  join login_bundles b
  on a.bundle_id = lower(b.bundleid)
  where a.identifier in ('loginFlowStart', 'accountPickerLoginSuccess', 'enterEmailLoginSuccess', 'enterPasswordLoginSuccess', 'eventPickerLoginSuccess','profileFillerLoginSuccess','webLoginSuccess')
  and a.binary_version >= '6'
  and a.binary_version not like '6.0%'
  and a.binary_version not like '6.1'
  and a.binary_version not like '6.1.%' 
  and a.binary_version not like '6.2'
  and a.binary_version not like '6.2.%' 
  and a.created::date >= current_date - (cast(extract(day from current_date) as int) - 1) - interval '6' month
  and a.batch_id >= (select min(id) from public.json_batch where task_id = 19 and last_read_at >= current_date - interval '2' day)
)
;

-- Insert New View Metrics into STG Table
insert into dashboard.kpi_login_view_metrics_STG (
  select a.*
  from fact_views_live a
  join login_bundles b
  on a.bundle_id = lower(b.bundleid)
  where identifier in ('accountPicker','enterEmail','enterPassword','remoteSsoLogin','resetPassword','eventPicker','profileFiller','eventProfileChoice')
  and a.binary_version >= '6'
  and a.binary_version not like '6.0%'
  and a.binary_version not like '6.1'
  and a.binary_version not like '6.1.%' 
  and a.binary_version not like '6.2'
  and a.binary_version not like '6.2.%' 
  and a.created::date >= current_date - (cast(extract(day from current_date) as int) - 1) - interval '6' month
  and a.batch_id >= (select min(id) from public.json_batch where task_id = 27 and last_read_at >= current_date - interval '2' day)
)
;

-- Delete (Last Batch ID Records and Older Records (> 6 Months)) & Vacuum from Final Checkpoint Metrics Table
delete from dashboard.kpi_login_checkpoint_metrics
where batch_id = (select min(id) from public.json_batch where task_id = 19 and last_read_at >= current_date - interval '2' day)
or created::date < current_date - (cast(extract(day from current_date) as int) - 1) - interval '6' month
;

vacuum dashboard.kpi_login_checkpoint_metrics
;

delete from dashboard.kpi_login_view_metrics
where batch_id = (select min(id) from public.json_batch where task_id = 27 and last_read_at >= current_date - interval '2' day)
or created::date < current_date - (cast(extract(day from current_date) as int) - 1) - interval '6' month
;

vacuum dashboard.kpi_login_view_metrics
;

-- Insert STG Records into Final Table
insert into dashboard.kpi_login_checkpoint_metrics (
  select *
  from dashboard.kpi_login_checkpoint_metrics_STG
)
;

insert into dashboard.kpi_login_view_metrics (
  select *
  from dashboard.kpi_login_view_metrics_STG
)
;





