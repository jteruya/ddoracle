select 'Devices' as label
     , weekspine.week_starting as "Week Starting"
     --, count(case when checklist.enterEmailMinDate is not null then 1 else null end)::decimal(8,2) as "Value"
     , count(*) as "Devices"
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
           and spine.device_type = 'ios'
           and bundles.bundle_type in ('open')
          ) checklist
on checklist.loginflowstartinitialenteremailmindate::date = weekspine.date
group by 1,2
order by 2
;