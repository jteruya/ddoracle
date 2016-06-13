-- Get 1st Session for Device
drop table if exists dashboard.kpi_login_devices_checklist_firstsessions;
create table dashboard.kpi_login_devices_checklist_firstsessions as
select a.device_id
     , a.bundle_id
     , min(created) as firstlogin
from fact_sessions_live a
join dashboard.kpi_login_devices_checklist b
on a.device_id = b.device_id
and a.bundle_id = b.bundle_id
where a.identifier = 'start'
group by 1,2
;