select 'Devices' as label
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     --, count(case when checklist.enterEmailMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , count(*) as "Devices"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
/*and spine.loginFlowStartNonInitialMinDate is null*/
and (spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '1' hour)
and spine.device_type = 'ios'
and bundles.bundle_type in ('closed')
group by 1,2
order by 2
;