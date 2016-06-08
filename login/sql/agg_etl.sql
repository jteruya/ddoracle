-- Classify Bundles (New)
drop table if exists dashboard.kpi_login_bundle_reg_type
;

create table dashboard.kpi_login_bundle_reg_type as
select lower(a.bundleid) as bundle_id
     , count(*) as eventcnt
     , count(case when b.canregister = true then 1 else null end) as openeventcnt
     , count(case when b.canregister = false then 1 else null end) as closedeventcnt
     , case
         when count(case when b.canregister = true then 1 else null end) > 0 and count(case when b.canregister = false then 1 else null end) = 0 then 'open'
         when count(case when b.canregister = false then 1 else null end) > 0 and count(case when b.canregister = true then 1 else null end) = 0 then 'closed'
         else 'mixed'
       end as bundle_type
from (select distinct aa.bundleid
      from eventcube.eventcubesummary ecs
      left join eventcube.testevents te
      on ecs.applicationid = te.applicationid
      join authdb_applications aa
      on ecs.applicationid = aa.applicationid
      where te.applicationid is null) a
join authdb_applications b
on a.bundleid = b.bundleid
group by 1;

-- Get Login Checkpoints
drop table if exists dashboard.kpi_login_checkpoint_metrics
;

create table dashboard.kpi_login_checkpoint_metrics as
select a.*
from fact_checkpoints_live a
join (select distinct aa.bundleid
      from eventcube.eventcubesummary ecs
      left join eventcube.testevents te
      on ecs.applicationid = te.applicationid
      join authdb_applications aa
      on ecs.applicationid = aa.applicationid
      where te.applicationid is null
      ) b
on a.bundle_id = lower(b.bundleid)
join (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) c
on a.created::date = c.date
where a.identifier in ('loginFlowStart', 'accountPickerLoginSuccess', 'enterEmailLoginSuccess', 'enterPasswordLoginSuccess', 'eventPickerLoginSuccess','profileFillerLoginSuccess','webLoginSuccess')
and a.binary_version >= '6.3'
;


-- Creat Index for Login Checkpoints Staging Table
create index indx_kpi_login_checkpoint_metrics on dashboard.kpi_login_checkpoint_metrics (bundle_id, device_id, device_type)
;

-- Get Login Views
drop table if exists dashboard.kpi_login_view_metrics
;

create table dashboard.kpi_login_view_metrics as
select a.*
from fact_views_live a
join (select distinct aa.bundleid
      from eventcube.eventcubesummary ecs
      left join eventcube.testevents te
      on ecs.applicationid = te.applicationid
      join authdb_applications aa
      on ecs.applicationid = aa.applicationid
      where te.applicationid is null
      ) b
on a.bundle_id = lower(b.bundleid)
join (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) c
on a.created::date = c.date
where identifier in ('accountPicker','enterEmail','enterPassword','remoteSsoLogin','resetPassword','eventPicker','profileFiller','eventProfileChoice')
and a.binary_version >= '6.3'
;

-- Creat Index for Login Views Staging Table
create index indx_kpi_login_view_metrics on dashboard.kpi_login_view_metrics (bundle_id, device_id, device_type)
;

-- Get Login Actions
drop table if exists dashboard.kpi_login_action_metrics
;

create table dashboard.kpi_login_action_metrics as
select a.*
from fact_actions_live a
join (select distinct aa.bundleid
      from eventcube.eventcubesummary ecs
      left join eventcube.testevents te
      on ecs.applicationid = te.applicationid
      join authdb_applications aa
      on ecs.applicationid = aa.applicationid
      where te.applicationid is null
      ) b
on a.bundle_id = lower(b.bundleid)
join (select wk.week_starting
           , date
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            where date <= current_date - 1 and date >= current_date - 60
            ) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek
      ) c
on a.created::date = c.date
where a.identifier in ('accountSelectButton','anotherAccountButton','enterEmailTextField','submitEmailButton','enterPasswordTextField','submitPasswordButton','resetPasswordButton','cancelResetPasswordButton','submitResetPasswordButton','eventSelectButton','changeProfilePhotoButton','cancelProfilePhotoAction','enterFirstNameTextField','enterLastNameTextField','enterCompanyTextField','enterTitleTextField','addSocialNetworkToProfileButton','submitProfileButton','createProfileButton','emailSupport')
and a.binary_version >= '6.3'
;

-- Creat Index for Login Actions Staging Table
create index indx_kpi_login_action_metrics on dashboard.kpi_login_action_metrics (bundle_id, device_id, device_type)
;


-- Device/Bundle Level Checkpoint Staging Table
drop table if exists dashboard.kpi_login_device_checkpoint_metrics;
create table dashboard.kpi_login_device_checkpoint_metrics as
select bundle_id
     , device_id
     , device_type

     -- Checkpoints
     -- loginFlowStart (Initial - enterEmail)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'enterEmail' then created else null end) as loginFlowStartInitialEnterEmailMinDate
     , max(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'enterEmail' then created else null end) as loginFlowStartInitialEnterEmailMaxDate
     , count(distinct case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'InitialView' = 'enterEmail' then session_id else null end) as loginFlowStartInitialEnterEmailSessionCnt

     -- loginFlowStart (Initial - accountPicker)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'accountPicker' then created else null end) as loginFlowStartInitialAccountPickerMinDate
     , max(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'accountPicker' then created else null end) as loginFlowStartInitialAccountPickerMaxDate
     , count(distinct case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'InitialView' = 'accountPicker' then session_id else null end) as loginFlowStartInitialAccountPickerSessionCnt
     
     -- accountPickerLoginSuccess (Initial - Open)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessInitialOpenMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessInitialOpenMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then session_id else null end) as accountPickerLoginSuccessInitialOpenSessionCnt

     -- enterEmailLoginSuccess (Initial - Open)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessInitialOpenMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessInitialOpenMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then session_id else null end) as enterEmailLoginSuccessInitialOpenSessionCnt  

     -- accountPickerLoginSuccess (Initial - Closed)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessInitialClosedMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessInitialClosedMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then session_id else null end) as accountPickerLoginSuccessInitialClosedSessionCnt

     -- enterEmailLoginSuccess (Initial - Closed)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessInitialClosedMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessInitialClosedMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then session_id else null end) as enterEmailLoginSuccessInitialClosedSessionCnt  
     
     -- enterPasswordLoginSuccess (Initial)
     , min(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as enterPasswordLoginSuccessInitialMinDate
     , max(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as enterPasswordLoginSuccessInitialMaxDate
     , count(distinct case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then session_id else null end) as enterPasswordLoginSuccessInitialSessionCnt  

     -- eventPickerLoginSuccess (Initial)
     , min(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as eventPickerLoginSuccessInitialMinDate
     , max(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as eventPickerLoginSuccessInitialMaxDate
     , count(distinct case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then session_id else null end) as eventPickerLoginSuccessInitialSessionCnt  

     -- profileFillerLoginSuccess (Initial)
     , min(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as profileFillerLoginSuccessInitialMinDate
     , max(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as profileFillerLoginSuccessInitialMaxDate
     , count(distinct case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then session_id else null end) as profileFillerLoginSuccessInitialSessionCnt  

     -- loginFlowStart (NonInitial)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false')  then created else null end) as loginFlowStartNonInitialMinDate
     , max(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as loginFlowStartNonInitialMaxDate
     , count(distinct case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as loginFlowStartNonInitialSessionCnt
     
     -- accountPickerLoginSuccess (NonInitial - Open)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessNonInitialOpenMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessNonInitialOpenMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and metadata->>'InitialLogin' = 'false' and metadata->>'EventRegType' = 'open' then session_id else null end) as accountPickerLoginSuccessNonInitialOpenSessionCnt

     -- enterEmailLoginSuccess (NonInitial - Open)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessNonInitialOpenMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessNonInitialOpenMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then session_id else null end) as enterEmailLoginSuccessNonInitialOpenSessionCnt  

     -- accountPickerLoginSuccess (NonInitial - Closed)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessNonInitialClosedMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessNonInitialClosedMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then session_id else null end) as accountPickerLoginSuccessNonInitialClosedSessionCnt

     -- enterEmailLoginSuccess (NonInitial - Closed)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessNonInitialClosedMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessNonInitialClosedMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then session_id else null end) as enterEmailLoginSuccessNonInitialClosedSessionCnt  
     
     -- enterPasswordLoginSuccess (NonInitial)
     , min(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as enterPasswordLoginSuccessNonInitialMinDate
     , max(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as enterPasswordLoginSuccessNonInitialMaxDate
     , count(distinct case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as enterPasswordLoginSuccessNonInitialSessionCnt  

     -- eventPickerLoginSuccess (NonInitial)
     , min(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as eventPickerLoginSuccessNonInitialMinDate
     , max(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as eventPickerLoginSuccessNonInitialMaxDate
     , count(distinct case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as eventPickerLoginSuccessNonInitialSessionCnt  

     -- profileFillerLoginSuccess (NonInitial)
     , min(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as profileFillerLoginSuccessNonInitialMinDate
     , max(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as profileFillerLoginSuccessNonInitialMaxDate
     , count(distinct case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as profileFillerLoginSuccessNonInitialSessionCnt         

from dashboard.kpi_login_checkpoint_metrics
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from dashboard.kpi_login_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;

-- Device/Bundle Level View Staging Table
drop table if exists dashboard.kpi_login_device_view_metrics;
create table dashboard.kpi_login_device_view_metrics as
select bundle_id
     , device_id
     , device_type
    
     -- Views & Actions
     -- accountPicker (View)
     , min(case when identifier = 'accountPicker' then created else null end) as accountPickerMinDate
     , max(case when identifier = 'accountPicker' then created else null end) as accountPickerMaxDate
     , count(distinct case when identifier = 'accountPicker' then session_id else null end) as accountPickerSessionCnt  
     
     -- enterEmail (View)
     , min(case when identifier = 'enterEmail' then created else null end) as enterEmailMinDate
     , max(case when identifier = 'enterEmail' then created else null end) as enterEmailMaxDate
     , count(distinct case when identifier = 'enterEmail' then session_id else null end) as enterEmailSessionCnt
       
     -- enterPassword (View)
     , min(case when identifier = 'enterPassword' then created else null end) as enterPasswordMinDate
     , max(case when identifier = 'enterPassword' then created else null end) as enterPasswordMaxDate
     , count(distinct case when identifier = 'enterPassword' then session_id else null end) as enterPasswordSessionCnt  
    
     -- resetPassword (View)
     , min(case when identifier = 'resetPassword' then created else null end) as resetPasswordMinDate
     , max(case when identifier = 'resetPassword' then created else null end) as resetPasswordMaxDate
     , count(distinct case when identifier = 'resetPassword' then session_id else null end) as resetPasswordSessionCnt       
             
      -- eventPicker (View)
     , min(case when identifier = 'eventPicker' then created else null end) as eventPickerMinDate
     , max(case when identifier = 'eventPicker' then created else null end) as eventPickerMaxDate
     , count(distinct case when identifier = 'eventPicker' then session_id else null end) as eventPickerSessionCnt  
     
     -- eventProfileChoice (View)
     , min(case when identifier = 'eventProfileChoice' then created else null end) as eventProfileChoiceMinDate
     , max(case when identifier = 'eventProfileChoice' then created else null end) as eventProfileChoiceMaxDate
     , count(distinct case when identifier = 'eventProfileChoice' then session_id else null end) as eventProfileChoiceSessionCnt  
    
     -- profileFiller (View)
     , min(case when identifier = 'profileFiller' then created else null end) as profileFillerMinDate
     , max(case when identifier = 'profileFiller' then created else null end) as profileFillerMaxDate
     , count(distinct case when identifier = 'profileFiller' then session_id else null end) as profileFillerSessionCnt  
             
from dashboard.kpi_login_view_metrics
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from dashboard.kpi_login_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;

-- Device/Bundle Level Action Staging Table
drop table if exists dashboard.kpi_login_device_action_metrics;
create table dashboard.kpi_login_device_action_metrics as
select bundle_id
     , device_id
     , device_type 

     -- accountSelectButton (Action)
     , min(case when identifier = 'accountSelectButton' then created else null end) as accountSelectButtonMinDate
     , max(case when identifier = 'accountSelectButton' then created else null end) as accountSelectButtonMaxDate
     , count(distinct case when identifier = 'accountSelectButton' then session_id else null end) as accountSelectButtonSessionCnt 

     -- anotherAccountButton (Action)
     , min(case when identifier = 'anotherAccountButton' then created else null end) as anotherAccountButtonMinDate
     , max(case when identifier = 'anotherAccountButton' then created else null end) as anotherAccountButtonMaxDate
     , count(distinct case when identifier = 'anotherAccountButton' then session_id else null end) as anotherAccountButtonSessionCnt 

     -- emailSupport (Action - Account Picker View)
     , min(case when identifier = 'emailSupport' and metadata->>'View' = 'accountPicker' then created else null end) as emailSupportAccountPickerMinDate
     , max(case when identifier = 'emailSupport' and metadata->>'View' = 'accountPicker' then created else null end) as emailSupportAccountPickerMaxDate
     , count(distinct case when identifier = 'emailSupport' and metadata->>'View' = 'accountPicker' then session_id else null end) as emailSupportAccountPickerSessionCnt
     
     -- enterEmailTextField (Action)
     , min(case when identifier = 'enterEmailTextField' then created else null end) as enterEmailTextFieldMinDate
     , max(case when identifier = 'enterEmailTextField' then created else null end) as enterEmailTextFieldMaxDate
     , count(distinct case when identifier = 'enterEmailTextField' then session_id else null end) as enterEmailTextFieldSessionCnt

     -- submitEmailButton (Action)
     , min(case when identifier = 'submitEmailButton' then created else null end) as submitEmailButtonMinDate
     , max(case when identifier = 'submitEmailButton' then created else null end) as submitEmailButtonMaxDate
     , count(distinct case when identifier = 'submitEmailButton' then session_id else null end) as submitEmailButtonSessionCnt

     -- emailSupport (Action - Enter Email View)
     , min(case when identifier = 'emailSupport' and metadata->>'View' = 'enterEmail' then created else null end) as emailSupportEnterEmailMinDate
     , max(case when identifier = 'emailSupport' and metadata->>'View' = 'enterEmail' then created else null end) as emailSupportEnterEmailMaxDate
     , count(distinct case when identifier = 'emailSupport' and metadata->>'View' = 'enterEmail' then session_id else null end) as emailSupportEnterEmailSessionCnt

     -- enterPasswordTextField (Action)
     , min(case when identifier = 'enterPasswordTextField' then created else null end) as enterPasswordTextFieldMinDate
     , max(case when identifier = 'enterPasswordTextField' then created else null end) as enterPasswordTextFieldMaxDate
     , count(distinct case when identifier = 'enterPassword' then session_id else null end) as enterPasswordTextFieldSessionCnt 

     -- submitPasswordButton (Action)
     , min(case when identifier = 'submitPasswordButton' then created else null end) as submitPasswordButtonMinDate
     , max(case when identifier = 'submitPasswordButton' then created else null end) as submitPasswordButtonMaxDate
     , count(distinct case when identifier = 'submitPasswordButton' then session_id else null end) as submitPasswordButtonSessionCnt 
     
     -- resetPasswordButton (Action)
     , min(case when identifier = 'resetPasswordButton' then created else null end) as resetPasswordButtonMinDate
     , max(case when identifier = 'resetPasswordButton' then created else null end) as resetPasswordButtonMaxDate
     , count(distinct case when identifier = 'resetPasswordButton' then session_id else null end) as resetPasswordButtonSessionCnt 

     -- cancelResetPasswordButton (Action)
     , min(case when identifier = 'cancelResetPasswordButton' then created else null end) as cancelResetPasswordButtonMinDate
     , max(case when identifier = 'cancelResetPasswordButton' then created else null end) as cancelResetPasswordButtonMaxDate
     , count(distinct case when identifier = 'cancelResetPasswordButton' then session_id else null end) as cancelResetPasswordButtonSessionCnt  

     -- submitResetPasswordButton (Action)
     , min(case when identifier = 'submitResetPasswordButton' then created else null end) as submitResetPasswordButtonMinDate
     , max(case when identifier = 'submitResetPasswordButton' then created else null end) as submitResetPasswordButtonMaxDate
     , count(distinct case when identifier = 'submitResetPasswordButton' then session_id else null end) as submitResetPasswordButtonSessionCnt       

     -- emailSupport (Action - Enter Password View)
     , min(case when identifier = 'emailSupport' and metadata->>'View' = 'enterPassword' then created else null end) as emailSupportEnterPasswordMinDate
     , max(case when identifier = 'emailSupport' and metadata->>'View' = 'enterPassword' then created else null end) as emailSupportEnterPasswordMaxDate
     , count(distinct case when identifier = 'emailSupport' and metadata->>'View' = 'enterPassword' then session_id else null end) as emailSupportEnterPasswordSessionCnt

      -- eventSelectButton (Action)
     , min(case when identifier = 'eventSelectButton' then created else null end) as eventSelectButtonMinDate
     , max(case when identifier = 'eventSelectButton' then created else null end) as eventSelectButtonMaxDate
     , count(distinct case when identifier = 'eventSelectButton' then session_id else null end) as eventSelectButtonSessionCnt 

     -- createProfileButton - Manual (Action)
     , min(case when identifier = 'createProfileButton' and metadata->>'Type' = 'manual' then created else null end) as createProfileButtonManualMinDate
     , max(case when identifier = 'createProfileButton' and metadata->>'Type' = 'manual' then created else null end) as createProfileButtonManualMaxDate
     , count(distinct case when identifier = 'createProfileButton' and metadata->>'Type' = 'manual' then session_id else null end) as createProfileButtonManualSessionCnt  

     -- createProfileButton (EPC View) - Import (Action)
     , min(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'eventProfileChoice' then created else null end) as createProfileButtonLinkedInEPCMinDate
     , max(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'eventProfileChoice' then created else null end) as createProfileButtonLinkedInEPCMaxDate
     , count(distinct case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'eventProfileChoice' then session_id else null end) as createProfileButtonLinkedInEPCSessionCnt  

     -- createProfileButton (PF View) - Import (Action)
     , min(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'profileFiller' then created else null end) as createProfileButtonLinkedInPFMinDate
     , max(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'profileFiller' then created else null end) as createProfileButtonLinkedInPFMaxDate
     , count(distinct case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'profileFiller' then session_id else null end) as createProfileButtonLinkedInPFSessionCnt

     -- changeProfilePhotoButton (Action)
     , min(case when identifier = 'changeProfilePhotoButton' then created else null end) as changeProfilePhotoButtonMinDate
     , max(case when identifier = 'changeProfilePhotoButton' then created else null end) as changeProfilePhotoButtonMaxDate
     , count(distinct case when identifier = 'changeProfilePhotoButton' then session_id else null end) as changeProfilePhotoButtonSessionCnt

     -- cancelProfilePhotoAction (Action)
     , min(case when identifier = 'cancelProfilePhotoAction' then created else null end) as cancelProfilePhotoActionMinDate
     , max(case when identifier = 'cancelProfilePhotoAction' then created else null end) as cancelProfilePhotoActionMaxDate
     , count(distinct case when identifier = 'cancelProfilePhotoAction' then session_id else null end) as cancelProfilePhotoActionSessionCnt

     -- enterFirstNameTextField (Action)
     , min(case when identifier = 'enterFirstNameTextField' then created else null end) as enterFirstNameTextFieldMinDate
     , max(case when identifier = 'enterFirstNameTextField' then created else null end) as enterFirstNameTextFieldMaxDate
     , count(distinct case when identifier = 'enterFirstNameTextField' then session_id else null end) as enterFirstNameTextFieldSessionCnt

     -- enterLastNameTextField (Action)
     , min(case when identifier = 'enterLastNameTextField' then created else null end) as enterLastNameTextFieldMinDate
     , max(case when identifier = 'enterLastNameTextField' then created else null end) as enterLastNameTextFieldMaxDate
     , count(distinct case when identifier = 'enterLastNameTextField' then session_id else null end) as enterLastNameTextFieldSessionCnt

     -- enterCompanyTextField (Action)
     , min(case when identifier = 'enterCompanyTextField' then created else null end) as enterCompanyTextFieldMinDate
     , max(case when identifier = 'enterCompanyTextField' then created else null end) as enterCompanyTextFieldMaxDate
     , count(distinct case when identifier = 'enterCompanyTextField' then session_id else null end) as enterCompanyTextFieldSessionCnt

     -- enterTitleTextField (Action)
     , min(case when identifier = 'enterTitleTextField' then created else null end) as enterTitleTextFieldMinDate
     , max(case when identifier = 'enterTitleTextField' then created else null end) as enterTitleTextFieldMaxDate
     , count(distinct case when identifier = 'enterTitleTextField' then session_id else null end) as enterTitleTextFieldSessionCnt

     -- addSocialNetworkToProfileButton (Action)
     , min(case when identifier = 'addSocialNetworkToProfileButton' then created else null end) as addSocialNetworkToProfileButtonMinDate
     , max(case when identifier = 'addSocialNetworkToProfileButton' then created else null end) as addSocialNetworkToProfileButtonMaxDate
     , count(distinct case when identifier = 'addSocialNetworkToProfileButton' then session_id else null end) as addSocialNetworkToProfileButtonSessionCnt

     -- submitProfileButton (Action)
     , min(case when identifier = 'submitProfileButton' then created else null end) as submitProfileButtonMinDate
     , max(case when identifier = 'submitProfileButton' then created else null end) as submitProfileButtonMaxDate
     , count(distinct case when identifier = 'submitProfileButton' then session_id else null end) as submitProfileButtonSessionCnt        
from dashboard.kpi_login_action_metrics a
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from dashboard.kpi_login_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;

-- Create a Device Spine
drop table if exists dashboard.kpi_login_devices;
create table dashboard.kpi_login_devices as
select distinct bundle_id
     , device_id
     , device_type
from dashboard.kpi_login_device_action_metrics
union
select distinct bundle_id
     , device_id
     , device_type
from dashboard.kpi_login_device_view_metrics
union
select distinct bundle_id
     ,device_id
     , device_type
from dashboard.kpi_login_device_checkpoint_metrics
;

-- Login Funnel at the Device/Bundle Level
drop table if exists dashboard.kpi_login_devices_checklist;
create table dashboard.kpi_login_devices_checklist as
select device.device_id
     , device.bundle_id
     , device.device_type
     
     , checkpoint.loginFlowStartInitialEnterEmailMinDate
     , checkpoint.loginFlowStartInitialAccountPickerMinDate
     , checkpoint.loginFlowStartNonInitialMinDate
     
     -- Account Picker
     , view.accountPickerMinDate
     , action.accountSelectButtonMinDate
     , action.anotherAccountButtonMinDate
     , action.emailSupportAccountPickerMinDate
     , checkpoint.accountPickerLoginSuccessInitialOpenMinDate
     , checkpoint.accountPickerLoginSuccessInitialClosedMinDate
     
     -- Enter Email
     , view.enterEmailMinDate
     , action.enterEmailTextFieldMinDate
     , action.submitEmailButtonMinDate
     , action.emailSupportEnterEmailMinDate
     , checkpoint.enterEmailLoginSuccessInitialOpenMinDate
     , checkpoint.enterEmailLoginSuccessInitialClosedMinDate
     
     -- Enter Password
     , view.enterPasswordMinDate
     , action.enterPasswordTextFieldMinDate
     , action.submitPasswordButtonMinDate
     , action.resetPasswordButtonMinDate
     , action.emailSupportEnterPasswordMinDate
     , checkpoint.enterPasswordLoginSuccessInitialMinDate
      
     -- Reset Password     
     , view.resetPasswordMinDate
     , action.cancelResetPasswordButtonMinDate
     , action.submitResetPasswordButtonMinDate

     -- Event Picker    
     , view.eventPickerMinDate
     , action.eventSelectButtonMinDate
     , checkpoint.eventPickerLoginSuccessInitialMinDate
     
     -- Event Choice
     , view.eventProfileChoiceMinDate
     , action.createProfileButtonManualMinDate
     , action.createProfileButtonLinkedInEPCMinDate
     
     -- Profile Filler
     , view.profileFillerMinDate
     , action.changeProfilePhotoButtonMinDate
     , action.cancelProfilePhotoActionMinDate
     , action.createProfileButtonLinkedInPFMinDate
     , action.enterFirstNameTextFieldMinDate
     , action.enterLastNameTextFieldMinDate
     , action.enterCompanyTextFieldMinDate
     , action.enterTitleTextFieldMinDate
     , action.addSocialNetworkToProfileButtonMinDate
     , action.submitProfileButtonMinDate
     , checkpoint.profileFillerLoginSuccessInitialMinDate
     
from dashboard.kpi_login_devices device
left join dashboard.kpi_login_device_checkpoint_metrics checkpoint
on device.device_id = checkpoint.device_id
and device.bundle_id = checkpoint.bundle_id
left join dashboard.kpi_login_device_view_metrics view
on device.device_id = view.device_id
and device.bundle_id = view.bundle_id
left join dashboard.kpi_login_device_action_metrics action
on device.device_id = action.device_id
and device.bundle_id = action.bundle_id
;

-- Get 1st Session for Device
drop table if exists dashboard.kpi_login_devices_checklist_firstsessions;
create table dashboard.kpi_login_devices_checklist_firstsessions as
select a.device_id
     , a.bundle_id
     , min(created) as firstlogin
from fact_sessions_live a
join dashboard.kpi_login_devices_checklist b
on a.device_id = b.device_id
and a.bundle_id = b.bundle_id
where a.identifier = 'start'
group by 1,2
;