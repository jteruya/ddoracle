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
	select a.*
	from fact_checkpoints_live a
	join login_bundles b
	on a.bundle_id = lower(b.bundleid)
	where a.identifier in ('loginFlowStart', 'accountPickerLoginSuccess', 'enterEmailLoginSuccess', 'enterPasswordLoginSuccess', 'eventPickerLoginSuccess','profileFillerLoginSuccess','webLoginSuccess')
	and a.binary_version >= '6.3'
	and a.created::date >= current_date - (cast(extract(day from current_date) as int) - 1) - interval '6' month
)
;

-- Insert into View Metrics Final Table
insert into dashboard.kpi_login_view_metrics (
	select a.*
	from fact_views_live a
	join login_bundles b
	on a.bundle_id = lower(b.bundleid)
	where identifier in ('accountPicker','enterEmail','enterPassword','remoteSsoLogin','resetPassword','eventPicker','profileFiller','eventProfileChoice')
	and a.binary_version >= '6.3'
	and a.created::date >= current_date - (cast(extract(day from current_date) as int) - 1) - interval '6' month
)
;