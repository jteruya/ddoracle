-- Increase Timeout Window to 180 minutes
--SET statement_timeout = '180 min';
--COMMIT;

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

-- Truncate & Vacuum STG Tables
truncate table dashboard.kpi_login_checkpoint_metrics_STG
;
vacuum dashboard.kpi_login_checkpoint_metrics_STG
;

truncate table dashboard.kpi_login_view_metrics_STG 
;
vacuum dashboard.kpi_login_view_metrics_STG
;

-- Insert New Checkpoint Metrics into STG Table
insert into dashboard.kpi_login_checkpoint_metrics_STG (
  select a.batch_id
       , a.row_id
       , a.tinserted
       , a.created
       , a.bundle_id
       , a.application_id
       , a.global_user_id
       , a.device_id
       , a.device_os_version
       , a.binary_version_new
       , a.mmm_info
       , a.identifier
       , a.metadata
       , a.schema_version
       , a.session_id
       , a.event_id
       , a.metric_type
       , a.anonymous_id 
       , a.device_type
       , a.metric_version
  from (select *
       , fn_parent_binaryversion(binary_version) as binary_version_new
  from fact_checkpoints_live
  where identifier in ('loginFlowStart', 'accountPickerLoginSuccess', 'enterEmailLoginSuccess', 'enterPasswordLoginSuccess', 'eventPickerLoginSuccess','profileFillerLoginSuccess','webLoginSuccess', 'eventProfileChoiceSuccess', 'passwordForkLoginSuccess', 'autoLoginSuccess', 'enterEmailLoginError')
  and binary_version >= '6'
  and created::date >= current_date - (cast(extract(day from current_date) as int) - 1) - interval '5' month
  and created::date <= current_date
  and batch_id >= (select min(id) from public.json_batch where task_id = 19 and last_read_at >= current_date - interval '2' day)) a
  join login_bundles b
  on a.bundle_id = lower(b.bundleid)
  where a.binary_version_new >= '6.03' 
)
;

-- Insert New View Metrics into STG Table
insert into dashboard.kpi_login_view_metrics_STG (
  select a.batch_id
       , a.row_id
       , a.tinserted
       , a.created
       , a.bundle_id
       , a.application_id
       , a.global_user_id
       , a.device_id
       , a.device_os_version
       , a.binary_version_new
       , a.mmm_info
       , a.identifier
       , a.metadata
       , a.schema_version
       , a.session_id
       , a.event_id
       , a.metric_type
       , a.anonymous_id 
       , a.device_type
       , a.metric_version
  from (select *
       , fn_parent_binaryversion(binary_version) as binary_version_new
  from fact_views_live
  where identifier in ('accountPicker','enterEmail','enterPassword','remoteSsoLogin','resetPassword','eventPicker','profileFiller','eventProfileChoice', 'passwordFork', 'emailLoginSent')
  and binary_version >= '6'
  and created::date >= current_date - (cast(extract(day from current_date) as int) - 1) - interval '5' month
  and created::date <= current_date
  and batch_id >= (select min(id) from public.json_batch where task_id = 27 and last_read_at >= current_date - interval '2' day)) a
  join login_bundles b
  on a.bundle_id = lower(b.bundleid)
  where a.binary_version_new >= '6.03' 
)
;

-- Delete (Last Batch ID Records and Older Records (> 6 Months)) & Vacuum from Final Checkpoint Metrics Table
delete from dashboard.kpi_login_checkpoint_metrics
where batch_id >= (select min(id) from public.json_batch where task_id = 19 and last_read_at >= current_date - interval '2' day)
or created::date < current_date - (cast(extract(day from current_date) as int) - 1) - interval '5' month
or created::date > current_date
;

vacuum dashboard.kpi_login_checkpoint_metrics
;

delete from dashboard.kpi_login_view_metrics
where batch_id >= (select min(id) from public.json_batch where task_id = 27 and last_read_at >= current_date - interval '2' day)
or created::date < current_date - (cast(extract(day from current_date) as int) - 1) - interval '5' month
or created::date > current_date
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





