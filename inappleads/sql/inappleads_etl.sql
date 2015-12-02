--================================================================================================================
--Menu Item Taps: Top of the Funnel
DROP TABLE IF EXISTS dashboard.inapp_taps;
CREATE TABLE dashboard.inapp_taps AS
SELECT DISTINCT Name, Global_User_Id, MIN(Created) AS FirstTap, MAX(Created) AS LastTap FROM (

--AnalyticsDB Historical dataset
SELECT app.Name, a.Global_User_Id, a.Created
FROM PUBLIC.Fact_Actions_Old a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE Identifier = 'menuitem'
AND a.Metadata ->> 'url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

UNION ALL

--oldMetrics Historical dataset
SELECT app.Name, a.Global_User_Id, a.Created
FROM PUBLIC.Fact_Actions a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE Identifier = 'menuitem'
AND a.Metadata ->> 'url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

UNION ALL

--oldMetrics Live dataset
SELECT app.Name, a.Global_User_Id, a.Created
FROM PUBLIC.Fact_Actions_New a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE a.Identifier = 'menuitem'
AND a.Metadata ->> 'url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

UNION ALL

--newMetrics dataset
SELECT app.Name, a.Global_User_Id, a.Created
FROM PUBLIC.Fact_Actions_Live a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE a.Identifier = 'menuItem'
AND a.Metadata ->> 'Url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

) t 
GROUP BY 1,2;

--================================================================================================================
-- Marketo Set
DROP VIEW IF EXISTS dashboard.inapp_marketo_leads;
CREATE OR REPLACE VIEW dashboard.inapp_marketo_leads AS
SELECT ProgramId, Email, SUBSTRING(Email,POSITION('@' IN Email)+1,999) AS Domain, fn_hashemail(Email) AS EmailHashed, MAX(UpdatedAt) AS LatestFormFillDate 
FROM Marketo.Leads 
WHERE ProgramId IN (1670,1593)
AND Email <> 'NULL'
GROUP BY 1,2,3;

--================================================================================================================
-- Get the SFDC Opportunities
CREATE OR REPLACE VIEW dashboard.inapp_sfdc_opps AS
SELECT 
CASE 
  WHEN a.SF_IsClosed = 'true' AND a.SF_IsWon = 'true' THEN 'Closed Won' 
  WHEN a.SF_IsClosed = 'true' AND a.SF_IsWon = 'false' THEN 'Closed Lost' 
  WHEN a.SF_IsClosed = 'false' AND a.SF_IsWon = 'false' THEN 'Open' 
END AS "Sales Pipeline",
a.SF_AccountId AS "Account", 
a.SF_Name AS "Event Name", 
a.SF_CreatedDate AS "Opportunity Created", 
a.SF_LastModifiedDate AS "Opportunity Last Modified", 
a.SF_Days_From_Create_To_Close__c AS "SalesForce - Days from Create to Closed", 
b.SF_Email_domain__c,
a.*
FROM Integrations.Opportunity a
LEFT JOIN Integrations.Account b ON a.SF_AccountId = b.SF_Id
WHERE a.SF_CampaignId LIKE '701E0000000apGd%' OR a.SF_CampaignId LIKE '701E0000000alw9%'
ORDER BY 1;