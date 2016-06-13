select 'EnterEmail' as "Label"
     , 1 as "Label Order"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "YYYYMM"
     , case
         when count(*) > 0 then cast((count(*)::decimal(8,2) - count(case when spine.enterPasswordMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(*)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Retention of Total Devices Value"    
     , count(*) as "Device Count"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
left join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
and ((sessions.firstLogin is null) or (sessions.firstLogin is not null and spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '10' minute))
and spine.device_type = 'android'
and bundles.bundle_type in ('closed')
and extract(year from spine.loginflowstartinitialmindate) * 100 + extract(month from spine.loginflowstartinitialmindate) >= 201602
and spine.loginflowstartinitialmindate::date <= current_date
and spine.loginflowstartinitialmindate::date <= bundles.lasteventenddate
group by 1,2,3

union

select 'EnterPassword' as "Label"
     , 2 as "Label Order"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "YYYYMM"
     , case
         when count(*) > 0 then cast((count(case when spine.enterPasswordMinDate is not null then 1 else null end)::decimal(8,2) - count(case when spine.eventPickerMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.enterPasswordMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Retention of Total Devices Value"      
     , count(case when spine.enterPasswordMinDate is not null then 1 else null end) as "Device Count"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
left join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
and ((sessions.firstLogin is null) or (sessions.firstLogin is not null and spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '10' minute))
and spine.device_type = 'android'
and bundles.bundle_type in ('closed')
and extract(year from spine.loginflowstartinitialmindate) * 100 + extract(month from spine.loginflowstartinitialmindate) >= 201602
and spine.loginflowstartinitialmindate::date <= current_date
and spine.loginflowstartinitialmindate::date <= bundles.lasteventenddate
group by 1,2,3

union

select 'EventPicker' as "Label"
     , 3 as "Label Order"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "YYYYMM"
     --, count(case when checklist.eventPickerMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , case
         when count(*) > 0 then cast((count(case when spine.eventPickerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when spine.profileFillerMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.eventPickerMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Retention of Total Devices Value"             
     , count(case when spine.eventPickerMinDate is not null then 1 else null end) as "Device Count"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
left join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
and ((sessions.firstLogin is null) or (sessions.firstLogin is not null and spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '10' minute))
and spine.device_type = 'android'
and bundles.bundle_type in ('closed')
and extract(year from spine.loginflowstartinitialmindate) * 100 + extract(month from spine.loginflowstartinitialmindate) >= 201602
and spine.loginflowstartinitialmindate::date <= current_date
and spine.loginflowstartinitialmindate::date <= bundles.lasteventenddate
group by 1,2,3

union 

select 'ProfileFiller' as "Label"
     , 4 as "Label Order"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "YYYYMM"
     , case
         when count(*) > 0 then cast((count(case when spine.profileFillerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.profileFillerMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Retention of Total Devices Value"          
     , count(case when spine.profileFillerMinDate is not null then 1 else null end) as "Device Count"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
left join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
and ((sessions.firstLogin is null) or (sessions.firstLogin is not null and spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '10' minute))
and spine.device_type = 'android'
and bundles.bundle_type in ('closed')
and extract(year from spine.loginflowstartinitialmindate) * 100 + extract(month from spine.loginflowstartinitialmindate) >= 201602
and spine.loginflowstartinitialmindate::date <= current_date
and spine.loginflowstartinitialmindate::date <= bundles.lasteventenddate
group by 1,2,3

union 

select 'ActivityFeed' as "Label"
     , 5 as "Label Order"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "YYYYMM"
     , case
         when count(*) > 0 then cast(count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "% Retention of Total Devices Value"    
     , count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as "Device Count"
from dashboard.kpi_login_devices_checklist spine
join dashboard.kpi_login_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
left join dashboard.kpi_login_devices_checklist_firstsessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialMinDate is not null)
and ((sessions.firstLogin is null) or (sessions.firstLogin is not null and spine.loginFlowStartInitialMinDate <= sessions.firstLogin + interval '10' minute))
and spine.device_type = 'android'
and bundles.bundle_type in ('closed')
and extract(year from spine.loginflowstartinitialmindate) * 100 + extract(month from spine.loginflowstartinitialmindate) >= 201602
and spine.loginflowstartinitialmindate::date <= current_date
and spine.loginflowstartinitialmindate::date <= bundles.lasteventenddate
group by 1,2,3

order by 2,3
;