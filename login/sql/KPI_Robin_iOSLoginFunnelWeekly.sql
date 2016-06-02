select case
          when bundles.bundle_type = 'open' then 'Open Bundle'
          when bundles.bundle_type = 'closed' then 'Closed Bundle'
          else 'Mixed Bundle'
       end as "Bundle Type"
     , cal.week_starting as "Week Starting"
     , count(*) as "Total App Count"  
     , count(case when enterEmailMinDate is not null then 1 else null end) as "Enter Email View"
     , count(case when enterPasswordMinDate is not null then 1 else null end) as "Enter Password View"
     --, count(case when resetPasswordMinDate is not null then 1 else null end) as "Reset Password View (Optional)"
     , count(case when eventPickerMinDate is not null then 1 else null end) as "Event Picker View"
     --, count(case when eventProfileChoiceMinDate is not null then 1 else null end) as "LinkedIn Import View (Optional)"
     , count(case when profileFillerMinDate is not null then 1 else null end) as "Profile Filler View"
     , count(case when profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as "Activity Feed"
from jt.pa506_logincube spine
join jt.pa506_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
join jt.pa506_logincube_sessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
join dashboard.calendar_wk cal
on spine.loginFlowStartInitialEnterEmailMinDate::date = cal.date
where (spine.loginFlowStartInitialEnterEmailMinDate is not null or spine.loginFlowStartInitialAccountPickerMinDate is not null)
and spine.loginFlowStartNonInitialMinDate is null
and ((spine.loginFlowStartInitialEnterEmailMinDate is not null and spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin) or (spine.loginFlowStartInitialAccountPickerMinDate is not null and spine.loginFlowStartInitialAccountPickerMinDate <= sessions.firstLogin))
and spine.device_type = 'ios'
and bundles.bundle_type in ('open', 'closed')
group by 1,2
order by 1,2
;