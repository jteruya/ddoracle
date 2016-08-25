-- Truncate & Vacuum Final Tables
truncate table dashboard.kpi_chat_action_metrics
;
vacuum dashboard.kpi_chat_action_metrics
;

truncate table dashboard.kpi_chat_view_metrics 
;
vacuum dashboard.kpi_chat_view_metrics
;

-- Get the List of all Non-Test Events
create temporary table login_events as
select distinct ecs.applicationid
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ECS.DirectMessaging = 1
;

-- Insert into Checkpoint Metrics Final Table
insert into dashboard.kpi_chat_action_metrics (
	select a.batch_id
	     , a.row_id
	     , a.tinserted
	     , a.created
	     , a.bundle_id
	     , a.application_id
	     , a.global_user_id
	     , a.device_id
	     , a.device_os_version
	     , a.binary_version
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
	from fact_actions_live a
	join login_events b
	on a.application_id = lower(b.applicationid)
	left join channels.rooms c
	on cast(a.Metadata->>'ChannelId' as bigint) = c.id
    WHERE (a.Identifier = 'chatTextButton' AND a.Metadata->>'Type' = 'submit' AND a.Metadata->>'ChannelId' ~ E'^\\d+$')
    OR (a.Identifier = 'chatProfileButton' AND a.Metadata->>'Type' = 'mute' AND a.Metadata->>'ChannelId' ~ E'^\\d+$')
)
;

insert into dashboard.kpi_chat_action_metrics (
	select a.batch_id
	     , a.row_id
	     , a.tinserted
	     , a.created
	     , a.bundle_id
	     , a.application_id
	     , a.global_user_id
	     , a.device_id
	     , a.device_os_version
	     , a.binary_version
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
	from fact_actions_live a
	join login_events b
	on a.application_id = lower(b.applicationid)
    WHERE (a.Identifier = 'menuItem' AND LOWER((a.metadata ->> 'Url'::text)) ~~ '%://messages%'::text)
)
;

-- Insert into View Metrics Final Table
insert into dashboard.kpi_chat_view_metrics (
	select a.batch_id
	     , a.row_id
	     , a.tinserted
	     , a.created
	     , a.bundle_id
	     , a.application_id
	     , a.global_user_id
	     , a.device_id
	     , a.device_os_version
	     , a.binary_version
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
	from fact_views_live a
	join login_events b
	on a.application_id = lower(b.applicationid)
	left join channels.rooms c
	on cast(a.Metadata->>'ChannelId' as bigint) = c.id
	where identifier in ('chat')
)
;