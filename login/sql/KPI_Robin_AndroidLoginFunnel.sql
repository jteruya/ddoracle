select case
          when bundles.bundle_type = 'open' then 'Open Bundle'
          when bundles.bundle_type = 'closed' then 'Closed Bundle'
          else 'Mixed Bundle'
       end as "Bundle Type"
     , count(*) as "Total App Count"
     , count(case when accountPickerMinDate is not null then 1 else null end) as "Account Picker View"
     , count(case when enterEmailMinDate is not null then 1 else null end) as "Enter Email View"
     , count(case when enterPasswordMinDate is not null then 1 else null end) as "Enter Password View"
     --, count(case when resetPasswordMinDate is not null then 1 else null end) as "Reset Password View (Optional) Device Count"
     , count(case when eventPickerMinDate is not null then 1 else null end) as "Event Picker View Device Count"
     --, count(case when eventProfileChoiceMinDate is not null then 1 else null end) as "LinkedIn Import View (Optional) Device Count"
     , count(case when profileFillerMinDate is not null then 1 else null end) as "Profile Filler View Count"
     , count(case when profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as "Activity Feed"
from jt.pa506_logincube spine
join jt.pa506_bundle_reg_type bundles
on spine.bundle_id = bundles.bundle_id
join jt.pa506_logincube_sessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialEnterEmailMinDate is not null or spine.loginFlowStartInitialAccountPickerMinDate is not null)
and spine.loginFlowStartNonInitialMinDate is null
and ((spine.loginFlowStartInitialEnterEmailMinDate is not null and spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin) or (spine.loginFlowStartInitialAccountPickerMinDate is not null and spine.loginFlowStartInitialAccountPickerMinDate <= sessions.firstLogin))
and spine.device_type = 'android'
and bundles.bundle_type in ('open', 'closed')
group by 1
order by 1
;