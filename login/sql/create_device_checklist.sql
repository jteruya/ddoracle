-- Create Temporary Device Checkpoint Checklist Table
create temporary table kpi_login_device_checkpoint_metrics as
select bundle_id
     , device_id
     , device_type
     
     , min(binary_version) as binary_version

     -- Checkpoints
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') then created else null end) as loginFlowStartInitialMinDate
     
     -- loginFlowStart (Initial - enterEmail)     
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'enterEmail' then created else null end) as loginFlowStartInitialEnterEmailMinDate

     -- loginFlowStart (Initial - accountPicker)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'accountPicker' then created else null end) as loginFlowStartInitialAccountPickerMinDate
     
     -- accountPickerLoginSuccess (Initial - Open)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessInitialOpenMinDate

     -- enterEmailLoginSuccess (Initial - Open)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessInitialOpenMinDate

     -- accountPickerLoginSuccess (Initial - Closed)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessInitialClosedMinDate

     -- enterEmailLoginSuccess (Initial - Closed)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessInitialClosedMinDate
     
     -- enterPasswordLoginSuccess (Initial)
     , min(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as enterPasswordLoginSuccessInitialMinDate

     -- eventPickerLoginSuccess (Initial)
     , min(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as eventPickerLoginSuccessInitialMinDate

     -- profileFillerLoginSuccess (Initial)
     , min(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as profileFillerLoginSuccessInitialMinDate

     -- loginFlowStart (NonInitial)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false')  then created else null end) as loginFlowStartNonInitialMinDate
     
     -- accountPickerLoginSuccess (NonInitial - Open)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessNonInitialOpenMinDate

     -- enterEmailLoginSuccess (NonInitial - Open)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessNonInitialOpenMinDate

     -- accountPickerLoginSuccess (NonInitial - Closed)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessNonInitialClosedMinDate

     -- enterEmailLoginSuccess (NonInitial - Closed)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessNonInitialClosedMinDate
     
     -- enterPasswordLoginSuccess (NonInitial)
     , min(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as enterPasswordLoginSuccessNonInitialMinDate

     -- eventPickerLoginSuccess (NonInitial)
     , min(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as eventPickerLoginSuccessNonInitialMinDate

     -- profileFillerLoginSuccess (NonInitial)
     , min(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as profileFillerLoginSuccessNonInitialMinDate     

from dashboard.kpi_login_checkpoint_metrics
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from dashboard.kpi_login_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;

-- Create Temporary Device View Checklist Table
create temporary table kpi_login_device_view_metrics as
select bundle_id
     , device_id
     , device_type

     , min(binary_version) as binary_version
    
     -- Views & Actions
     -- accountPicker (View)
     , min(case when identifier = 'accountPicker' then created else null end) as accountPickerMinDate
     
     -- enterEmail (View)
     , min(case when identifier = 'enterEmail' then created else null end) as enterEmailMinDate
       
     -- enterPassword (View)
     , min(case when identifier = 'enterPassword' then created else null end) as enterPasswordMinDate
    
     -- resetPassword (View)
     , min(case when identifier = 'resetPassword' then created else null end) as resetPasswordMinDate      
             
      -- eventPicker (View)
     , min(case when identifier = 'eventPicker' then created else null end) as eventPickerMinDate 
     
     -- eventProfileChoice (View)
     , min(case when identifier = 'eventProfileChoice' then created else null end) as eventProfileChoiceMinDate
    
     -- profileFiller (View)
     , min(case when identifier = 'profileFiller' then created else null end) as profileFillerMinDate  
             
from dashboard.kpi_login_view_metrics
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from dashboard.kpi_login_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;

-- Create a Temporary Device Spine Table
create temporary table kpi_login_devices as
select bundle_id
     , device_id
     , device_type
     , min(binary_version) as binary_version
from (select distinct bundle_id
           , device_id
           , device_type
           , binary_version
      from kpi_login_device_view_metrics
      union
      select distinct bundle_id
           , device_id
           , device_type
           , binary_version
      from kpi_login_device_checkpoint_metrics
     ) a
group by 1,2,3
;

-- Create Final Checklist Table
drop table if exists dashboard.kpi_login_devices_checklist;
create table dashboard.kpi_login_devices_checklist as
select device.device_id
     , device.bundle_id
     , device.device_type
     , device.binary_version
     
     , checkpoint.loginFlowStartInitialMinDate
     , checkpoint.loginFlowStartInitialEnterEmailMinDate
     , checkpoint.loginFlowStartInitialAccountPickerMinDate
     , checkpoint.loginFlowStartNonInitialMinDate
     
     -- Account Picker
     , view.accountPickerMinDate
     , checkpoint.accountPickerLoginSuccessInitialOpenMinDate
     , checkpoint.accountPickerLoginSuccessInitialClosedMinDate
     
     -- Enter Email
     , view.enterEmailMinDate
     , checkpoint.enterEmailLoginSuccessInitialOpenMinDate
     , checkpoint.enterEmailLoginSuccessInitialClosedMinDate
     
     -- Enter Password
     , view.enterPasswordMinDate
     , checkpoint.enterPasswordLoginSuccessInitialMinDate
      
     -- Reset Password     
     , view.resetPasswordMinDate

     -- Event Picker    
     , view.eventPickerMinDate
     , checkpoint.eventPickerLoginSuccessInitialMinDate
     
     -- Event Choice
     , view.eventProfileChoiceMinDate
     
     -- Profile Filler
     , view.profileFillerMinDate
     , checkpoint.profileFillerLoginSuccessInitialMinDate
     
from kpi_login_devices device
left join kpi_login_device_checkpoint_metrics checkpoint
on device.device_id = checkpoint.device_id
and device.bundle_id = checkpoint.bundle_id
left join kpi_login_device_view_metrics view
on device.device_id = view.device_id
and device.bundle_id = view.bundle_id
;
