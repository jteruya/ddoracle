-- Increase Timeout Window to 180 minutes
--SET statement_timeout = '180 min';
--COMMIT;

-- Get the List of all Non-Test Events
create temporary table login_events as
select distinct ecs.applicationid
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ECS.DirectMessaging = 1
;

-- Truncate & Vacuum STG Tables
truncate table dashboard.kpi_chat_action_metrics_STG
;
vacuum dashboard.kpi_chat_action_metrics_STG
;

truncate table dashboard.kpi_chat_view_metrics_STG 
;
vacuum dashboard.kpi_chat_view_metrics_STG
;

insert into dashboard.kpi_chat_action_metrics_STG (
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
       , NULL as Type
       , NULL as RoomType
       , NULL as ChannelId
  from (select *
             , fn_parent_binaryversion(binary_version) as binary_version_new
        from fact_actions_live
        WHERE ((Identifier = 'chatTextButton' AND Metadata->>'Type' = 'submit' AND Metadata->>'ChannelId' ~ E'^\\d+$')
        OR (Identifier = 'chatProfileButton' AND Metadata->>'Type' = 'mute' AND Metadata->>'ChannelId' ~ E'^\\d+$'))
        AND batch_id >= (select min(id) from public.json_batch where task_id = 22 and last_read_at >= current_date - interval '2' day)) a
  join login_events b
  on a.application_id = lower(b.applicationid)
  left join channels.rooms c
  on cast(a.Metadata->>'ChannelId' as bigint) = c.id
)
;

insert into dashboard.kpi_chat_action_metrics_STG (
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
       , NULL as Type
       , NULL as RoomType
       , NULL as ChannelId
  from (select *
             , fn_parent_binaryversion(binary_version) as binary_version_new
        from fact_actions_live
        where (Identifier = 'menuItem' AND LOWER((metadata ->> 'Url'::text)) ~~ '%://messages%'::text)
        and batch_id >= (select min(id) from public.json_batch where task_id = 22 and last_read_at >= current_date - interval '2' day)) a
  join login_events b
  on a.application_id = lower(b.applicationid)
)
;

-- Insert New View Metrics into STG Table
insert into dashboard.kpi_chat_view_metrics_STG (
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
       , a.Metadata->>'Type' as Type
       , c.Type as RoomType
       , c.Id as ChannelId  
  from (select *
             , fn_parent_binaryversion(binary_version) as binary_version_new
        from fact_views_live
        where identifier in ('chat')
        and batch_id >= (select min(id) from public.json_batch where task_id = 27 and last_read_at >= current_date - interval '2' day)) a
  join login_events b
  on a.application_id = lower(b.applicationid)
  left join channels.rooms c
  on cast(a.Metadata->>'ChannelId' as bigint) = c.id
)
;


-- Delete (Last Batch ID Records and Older Records (> 6 Months)) & Vacuum from Final Checkpoint Metrics Table
delete from dashboard.kpi_chat_action_metrics
where batch_id >= (select min(id) from public.json_batch where task_id = 22 and last_read_at >= current_date - interval '2' day)
;

vacuum dashboard.kpi_chat_action_metrics
;



delete from dashboard.kpi_chat_view_metrics
where batch_id >= (select min(id) from public.json_batch where task_id = 27 and last_read_at >= current_date - interval '2' day)
;

vacuum dashboard.kpi_chat_view_metrics
;


-- Insert STG Records into Final Table
insert into dashboard.kpi_chat_action_metrics (
  select *
  from dashboard.kpi_chat_action_metrics_STG
)
;

insert into dashboard.kpi_chat_view_metrics (
  select *
  from dashboard.kpi_chat_view_metrics_STG
)
;