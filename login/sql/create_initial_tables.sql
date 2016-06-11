-- Drop (STG and Final) Tables if Exists
drop table if exists dashboard.kpi_login_checkpoint_metrics_STG
;

drop table if exists dashboard.kpi_login_view_metrics_STG
;

drop table if exists dashboard.kpi_login_checkpoint_metrics
;

drop table if exists dashboard.kpi_login_view_metrics
;

-- Create (STG and Final) Tables
create table dashboard.kpi_login_checkpoint_metrics_STG as
select *
from fact_checkpoints_live
limit 0
;

create table dashboard.kpi_login_view_metrics_STG as
select *
from fact_views_live
limit 0
;

create table dashboard.kpi_login_checkpoint_metrics as
select *
from fact_checkpoints_live
limit 0
;

create table dashboard.kpi_login_view_metrics as
select *
from fact_views_live
limit 0
;

-- Create Indexes on Final Tables
create index indx_kpi_login_checkpoint_metrics on dashboard.kpi_login_checkpoint_metrics (bundle_id, device_id, device_type)
;

create index indx_kpi_login_view_metrics on dashboard.kpi_login_view_metrics (bundle_id, device_id, device_type)
;
