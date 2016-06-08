-- iOS Total Device Count (Open Bundle)
select 'EnterEmail' as "Step Name"
     , 1 as "Step Number"
     , weekspine.week_starting as "Week Starting"
     , case
         when count(*) > 0 then cast((count(case when checklist.enterEmailMinDate is not null or checklist.accountPickerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when checklist.eventPickerMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
from (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) weekspine
left join (select *
           from dashboard.kpi_login_devices_checklist spine
           join dashboard.kpi_login_bundle_reg_type bundles
           on spine.bundle_id = bundles.bundle_id
           join dashboard.kpi_login_devices_checklist_firstsessions sessions
           on spine.bundle_id = sessions.bundle_id
           and spine.device_id = sessions.device_id
           where (spine.loginFlowStartInitialEnterEmailMinDate is not null)
           and spine.loginFlowStartNonInitialMinDate is null
           and (spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin)
           and spine.device_type = 'android'
           and bundles.bundle_type in ('open')
          ) checklist
on checklist.loginflowstartinitialenteremailmindate::date = weekspine.date
group by 1,2,3

union

select 'EventPicker' as "Step Name"
     , 2 as "Step Number"
     , weekspine.week_starting as "Week Starting"
     --, count(case when checklist.eventPickerMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , case
         when count(*) > 0 then cast((count(case when checklist.eventPickerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when checklist.profileFillerMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
from (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) weekspine
left join (select *
           from dashboard.kpi_login_devices_checklist spine
           join dashboard.kpi_login_bundle_reg_type bundles
           on spine.bundle_id = bundles.bundle_id
           join dashboard.kpi_login_devices_checklist_firstsessions sessions
           on spine.bundle_id = sessions.bundle_id
           and spine.device_id = sessions.device_id
           where (spine.loginFlowStartInitialEnterEmailMinDate is not null)
           and spine.loginFlowStartNonInitialMinDate is null
           and (spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin)
           and spine.device_type = 'android'
           and bundles.bundle_type in ('open')
          ) checklist
on checklist.loginflowstartinitialenteremailmindate::date = weekspine.date
group by 1,2,3

union 

select 'ProfileFiller' as "Step Name"
     , 3 as "Step Number"
     , weekspine.week_starting as "Week Starting"
     --, count(case when checklist.profileFillerMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     /*, case
         when count(*) > 0 then cast(count(case when checklist.eventPickerMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) - count(case when checklist.profileFillerMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Value"*/
     , case
         when count(*) > 0 then cast((count(case when checklist.profileFillerMinDate is not null then 1 else null end)::decimal(8,2) - count(case when checklist.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2))/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
from (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) weekspine
left join (select *
           from dashboard.kpi_login_devices_checklist spine
           join dashboard.kpi_login_bundle_reg_type bundles
           on spine.bundle_id = bundles.bundle_id
           join dashboard.kpi_login_devices_checklist_firstsessions sessions
           on spine.bundle_id = sessions.bundle_id
           and spine.device_id = sessions.device_id
           where (spine.loginFlowStartInitialEnterEmailMinDate is not null)
           and spine.loginFlowStartNonInitialMinDate is null
           and (spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin)
           and spine.device_type = 'android'
           and bundles.bundle_type in ('open')
          ) checklist
on checklist.loginflowstartinitialenteremailmindate::date = weekspine.date
group by 1,2,3

union 

select 'ActivityFeed' as "Step Name"
     , 4 as "Step Number"
     , weekspine.week_starting as "Week Starting"
     --, count(case when checklist.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , case
         when count(*) > 0 then cast(count(case when checklist.profileFillerLoginSuccessInitialMinDate is not null then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) * 100 as decimal(5,2))
         else null
       end as "Step Drop Off Value"
from (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) weekspine
left join (select *
           from dashboard.kpi_login_devices_checklist spine
           join dashboard.kpi_login_bundle_reg_type bundles
           on spine.bundle_id = bundles.bundle_id
           join dashboard.kpi_login_devices_checklist_firstsessions sessions
           on spine.bundle_id = sessions.bundle_id
           and spine.device_id = sessions.device_id
           where (spine.loginFlowStartInitialEnterEmailMinDate is not null)
           and spine.loginFlowStartNonInitialMinDate is null
           and (spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin)
           and spine.device_type = 'android'
           and bundles.bundle_type in ('open')
          ) checklist
on checklist.loginflowstartinitialenteremailmindate::date = weekspine.date
group by 1,2,3

order by 2,3
;