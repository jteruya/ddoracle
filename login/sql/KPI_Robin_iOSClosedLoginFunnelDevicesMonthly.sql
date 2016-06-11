select 'Devices' as label
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     --, count(case when checklist.enterEmailMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , count(*) as "Devices"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
left join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
/*and spine.loginFlowStartNonInitialMinDate is null*/
and ((sessions.firstLogin is null) or (sessions.firstLogin is not null and spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '10' minute))
and spine.device_type = 'ios'
and bundles.bundle_type in ('closed')
and extract(year from spine.loginflowstartinitialmindate) * 100 + extract(month from spine.loginflowstartinitialmindate) >= 201602
and spine.loginflowstartinitialmindate::date <= current_date
group by 1,2
order by 2
;