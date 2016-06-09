select 'EnterEmail' as "Step Name"
     , 1 as "Step Number"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     , case
         when count(*) > 0 then cast((count(*)::decimal(8,2) - count(case when spine.eventPickerMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(*)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Display Total Drop Off Value"    
     , count(*) as "Device Count"
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
and bundles.bundle_type in ('open')
group by 1,2,3

union

select 'EnterPassword' as "Step Name"
     , 2 as "Step Number"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     , 0 as "Step Drop Off Value"
     , 0 as "Display Total Drop Off Value"      
     , count(case when spine.enterPasswordMinDate is not null then 1 else null end) as "Device Count"
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
and bundles.bundle_type in ('open')
group by 1,2,3

union

select 'EventPicker' as "Step Name"
     , 3 as "Step Number"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     --, count(case when checklist.eventPickerMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , case
         when count(*) > 0 then cast((count(case when spine.eventPickerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when spine.profileFillerMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.eventPickerMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Display Total Drop Off Value"             
     , count(case when spine.eventPickerMinDate is not null then 1 else null end) as "Device Count"
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
and bundles.bundle_type in ('open')
group by 1,2,3

union 

select 'ProfileFiller' as "Step Name"
     , 4 as "Step Number"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     , case
         when count(*) > 0 then cast((count(case when spine.profileFillerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.profileFillerMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Display Total Drop Off Value"          
     , count(case when spine.profileFillerMinDate is not null then 1 else null end) as "Device Count"
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
and bundles.bundle_type in ('open')
group by 1,2,3

union 

select 'ActivityFeed' as "Step Name"
     , 5 as "Step Number"
     , extract(year from spine.loginflowstartinitialmindate) || '-' || extract(month from spine.loginflowstartinitialmindate) as "Month"
     --, count(case when checklist.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , case
         when count(*) > 0 then cast(count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
     , case
         when count(*) > 0 then cast(count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Display Total Drop Off Value"    
     , count(case when spine.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as "Device Count"
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
and bundles.bundle_type in ('open')
group by 1,2,3

order by 2,3
;