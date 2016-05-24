select 'Week of ' || cast(time_spine.week_starting as text)
     --, count(*) as InitialLoginOpen

     , count(case when enterEmailMinDate is not null then 1 else null end) as enterEmail
     /*, count(case when enterEmailTextFieldMinDate is not null then 1 else null end) as enterEmailTextField
     , count(case when submitEmailButtonMinDate is not null then 1 else null end) as submitEmailButton
     , count(case when emailSupportEnterEmailMinDate is not null then 1 else null end) as emailSupportEnterEmail*/
     --, count(case when enterEmailLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is null then 1 else null end) as enterEmailLoginSuccessInitialOpen
     --, count(case when enterEmailLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is not null then 1 else null end) as enterEmailLoginSuccessInitialMixed
     --, count(case when enterEmailLoginSuccessInitialClosedMinDate is not null and enterEmailLoginSuccessInitialOpenMinDate is null then 1 else null end) as enterEmailLoginSuccessInitialClosed
     
     , count(case when enterPasswordMinDate is not null then 1 else null end) as enterPassword
     /*, count(case when enterPasswordTextFieldMinDate is not null then 1 else null end) as enterPasswordTextField
     , count(case when submitPasswordButtonMinDate is not null then 1 else null end) as submitPasswordButton
     , count(case when resetPasswordButtonMinDate is not null then 1 else null end) as resetPasswordButton
     , count(case when emailSupportEnterPasswordMinDate is not null then 1 else null end) as emailSupportEnterPassword
     , count(case when enterPasswordLoginSuccessInitialMinDate is not null then 1 else null end) as enterPasswordLoginSuccessInitial
     */
     
     , count(case when resetPasswordMinDate is not null then 1 else null end) as resetPassword
     /*, count(case when cancelResetPasswordButtonMinDate is not null then 1 else null end) as cancelResetPasswordButton
     , count(case when submitResetPasswordButtonMinDate is not null then 1 else null end) as submitResetPasswordButton
     
     , count(case when eventPickerMinDate is not null then 1 else null end) as eventPicker
     , count(case when eventSelectButtonMinDate is not null then 1 else null end) as eventSelectButton
     
     , count(case when eventPickerLoginSuccessInitialMinDate is not null then 1 else null end) as eventPickerLoginSuccessInitial
     */
     
     , count(case when eventProfileChoiceMinDate is not null then 1 else null end) as eventProfileChoice
     /*, count(case when createProfileButtonManualMinDate is not null and createProfileButtonLinkedInEPCMinDate is null then 1 else null end) as createProfileButtonManual
     , count(case when createProfileButtonLinkedInEPCMinDate is not null and createProfileButtonManualMinDate is null then 1 else null end) createProfileButtonLinkedInEPC
     , count(case when createProfileButtonManualMinDate is not null and createProfileButtonLinkedInEPCMinDate is not null then 1 else null end) as createProfileButtonBoth
     
     */
     , count(case when profileFillerMinDate is not null then 1 else null end) as profileFiller
     /*, count(case when changeProfilePhotoButtonMinDate is not null then 1 else null end) as changeProfilePhotoButton
     , count(case when cancelProfilePhotoActionMinDate is not null then 1 else null end) as cancelProfilePhotoAction
     , count(case when createProfileButtonLinkedInPFMinDate is not null then 1 else null end) createProfileButtonLinkedInPF
     , count(case when enterFirstNameTextFieldMinDate is not null then 1 else null end) as enterFirstNameTextField
     , count(case when enterLastNameTextFieldMinDate is not null then 1 else null end) as enterLastNameTextField
     , count(case when enterCompanyTextFieldMinDate is not null then 1 else null end) as enterCompanyTextField
     , count(case when enterTitleTextFieldMinDate is not null then 1 else null end) as enterTitleTextField
     , count(case when addSocialNetworkToProfileButtonMinDate is not null then 1 else null end) as addSocialNetworkToProfileButton
     , count(case when submitProfileButtonMinDate is not null then 1 else null end) as submitProfileButton
     */
     , count(case when profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as profileFillerLoginSuccessInitial

from (select calendar.week_no
           , calendar.date
           , calendar.week_starting
           , bundle_type.bundle_type
      from dashboard.calendar_wk calendar
      join (select cast('open' as text) as bundle_type) bundle_type
      on 1 = 1
      --where calendar.date >= current_date - interval '1' month
      --and calendar.date < current_date
      where calendar.date >= '2016-02-01'
      and calendar.date <= '2016-03-31'
      order by 1,2,3
      ) time_spine
left join (select bundles.bundle_type
                , spine.*
           from jt.pa506_logincube spine
           join jt.pa506_bundle_reg_type bundles
           on spine.bundle_id = bundles.bundle_id
           join jt.pa506_logincube_sessions sessions
           on spine.bundle_id = sessions.bundle_id
           and spine.device_id = sessions.device_id
           where (spine.loginFlowStartInitialEnterEmailMinDate is not null)
           and spine.loginFlowStartNonInitialMinDate is null
           and (spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin)
           ) logincube
on logincube.loginFlowStartInitialEnterEmailMinDate::date = time_spine.date
and logincube.bundle_type = time_spine.bundle_type
/*join (select *
      from jt.pa506_bundle_reg_type
      where bundle_tolerance <= 0.1) bundles
on spine.bundle_id = bundles.bundle_id
join jt.pa506_logincube_sessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id*/

and logincube.device_type = 'ios'
and logincube.bundle_type = 'open'
group by 1
order by 1
;