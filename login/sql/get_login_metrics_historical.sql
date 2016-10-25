-- Truncate & Vacuum Final Tables
truncate table dashboard.kpi_login_checkpoint_metrics
;
vacuum dashboard.kpi_login_checkpoint_metrics
;

truncate table dashboard.kpi_login_view_metrics 
;
vacuum dashboard.kpi_login_view_metrics
;

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

-- Insert into Checkpoint Metrics Final Table
insert into dashboard.kpi_login_checkpoint_metrics (
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
	      and created::date <= current_date) a
	join login_bundles b
	on a.bundle_id = lower(b.bundleid)
	where binary_version_new >= '6.03'
)
;

-- Insert into View Metrics Final Table
insert into dashboard.kpi_login_view_metrics (
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
	      and created::date <= current_date) a
	join login_bundles b
	on a.bundle_id = lower(b.bundleid)
	where binary_version_new >= '6.03'	
)
;
