-- Drop (STG and Final) Tables if Exists
drop table if exists dashboard.kpi_chat_action_metrics_STG
;

drop table if exists dashboard.kpi_chat_view_metrics_STG
;

drop table if exists dashboard.kpi_chat_action_metrics
;

drop table if exists dashboard.kpi_chat_view_metrics
;

-- Create (STG and Final) Tables
create table dashboard.kpi_chat_action_metrics_STG (
	batch_id int,
	row_id int,
	tinserted timestamp,
	created timestamp,
	bundle_id varchar,
	application_id varchar,
	global_user_id varchar,
	device_id varchar,
	device_os_version varchar,
	binary_version varchar,
	mmm_info varchar,
	identifier varchar,
	metadata jsonb,
	schema_version int,
	session_id varchar,
	event_id int,
	metric_type varchar,
	anonymous_id varchar,
	device_type varchar,
	metric_version int,
	type varchar,
	room_type varchar,
	channel_id bigint
)
;

create table dashboard.kpi_chat_view_metrics_STG (
	batch_id int,
	row_id int,
	tinserted timestamp,
	created timestamp,
	bundle_id varchar,
	application_id varchar,
	global_user_id varchar,
	device_id varchar,
	device_os_version varchar,
	binary_version varchar,
	mmm_info varchar,
	identifier varchar,
	metadata jsonb,
	schema_version int,
	session_id varchar,
	event_id int,
	metric_type varchar,
	anonymous_id varchar,
	device_type varchar,
	metric_version int,
	type varchar,
	room_type varchar,
	channel_id bigint
)
;

create table dashboard.kpi_chat_action_metrics (
	batch_id int,
	row_id int,
	tinserted timestamp,
	created timestamp,
	bundle_id varchar,
	application_id varchar,
	global_user_id varchar,
	device_id varchar,
	device_os_version varchar,
	binary_version varchar,
	mmm_info varchar,
	identifier varchar,
	metadata jsonb,
	schema_version int,
	session_id varchar,
	event_id int,
	metric_type varchar,
	anonymous_id varchar,
	device_type varchar,
	metric_version int,
	type varchar,
	room_type varchar,
	channel_id bigint
)
;

create table dashboard.kpi_chat_view_metrics (
	batch_id int,
	row_id int,
	tinserted timestamp,
	created timestamp,
	bundle_id varchar,
	application_id varchar,
	global_user_id varchar,
	device_id varchar,
	device_os_version varchar,
	binary_version varchar,
	mmm_info varchar,
	identifier varchar,
	metadata jsonb,
	schema_version int,
	session_id varchar,
	event_id int,
	metric_type varchar,
	anonymous_id varchar,
	device_type varchar,
	metric_version int,
	type varchar,
	room_type varchar,
	channel_id bigint
)
;

-- Create Indexes on Final Tables
create index indx_kpi_chat_action_metrics on dashboard.kpi_chat_action_metrics (application_id)
;

create index indx_kpi_chat_view_metrics on dashboard.kpi_chat_view_metrics (application_id)
;