--================================================================================================================
--Menu Item Taps: Top of the Funnel
DROP TABLE IF EXISTS dashboard.inapp_taps;
CREATE TABLE dashboard.inapp_taps AS
SELECT DISTINCT StartDate, YYYY_MM, Name, Global_User_Id, MIN(Created) AS FirstTap, MAX(Created) AS LastTap FROM (

--AnalyticsDB Historical dataset
SELECT app.Name, a.Global_User_Id, a.Created, app.StartDate, 
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM
FROM PUBLIC.Fact_Actions_Old a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE Identifier = 'menuitem'
AND UPPER(a.Application_Id) NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND a.Metadata ->> 'url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

UNION ALL

--oldMetrics Historical dataset
SELECT app.Name, a.Global_User_Id, a.Created, app.StartDate, 
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM
FROM PUBLIC.Fact_Actions a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE Identifier = 'menuitem'
AND UPPER(a.Application_Id) NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND a.Metadata ->> 'url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

UNION ALL

--oldMetrics Live dataset
SELECT app.Name, a.Global_User_Id, a.Created, app.StartDate, 
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM
FROM PUBLIC.Fact_Actions_New a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE a.Identifier = 'menuitem'
AND UPPER(a.Application_Id) NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND a.Metadata ->> 'url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

UNION ALL

--newMetrics dataset
SELECT app.Name, a.Global_User_Id, a.Created, app.StartDate, 
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM
FROM PUBLIC.Fact_Actions_Live a
JOIN PUBLIC.AuthDB_Applications app ON UPPER(a.Application_id) = app.ApplicationId
WHERE a.Identifier = 'menuItem'
AND UPPER(a.Application_Id) NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND a.Metadata ->> 'Url' = 'http://doubledutch.me/mobile-about.html'
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'390 days')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'390 days')||'-01 00:00:00' AS TIMESTAMP) --Past 390 Days

) t 
GROUP BY 1,2,3,4;

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

--================================================================================================================
--User Aggregate Funnel
DROP TABLE IF EXISTS dashboard.inapp_user_agg;
CREATE TABLE dashboard.inapp_user_agg AS

SELECT
  base.YYYY_MM AS "Year-Month",
  active."Active Users",
  base."Users Tapped",
  COALESCE(webform.CNT,0) AS "Users completed Web Form"
  
FROM (
	SELECT 
	YYYY_MM, COUNT(*) AS "Users Tapped"
	FROM dashboard.inapp_taps
	WHERE YYYY_MM IS NOT NULL
	AND StartDate < CURRENT_DATE
	AND StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 month')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 month')||'-01 00:00:00' AS TIMESTAMP) --Past 13 Months
	GROUP BY 1
) base

LEFT JOIN (
	SELECT CAST(EXTRACT(YEAR FROM CreatedAt) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM CreatedAt) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM CreatedAt) AS INT) AS YYYY_MM, COUNT(*) AS CNT
	FROM Marketo.Leads
	WHERE ProgramId IN (1670,1593)
	AND Email <> 'NULL'
	GROUP BY 1
) webform ON base.YYYY_MM = webform.YYYY_MM 

LEFT JOIN (
        SELECT CAST(EXTRACT(YEAR FROM b.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM b.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM b.StartDate) AS INT) AS YYYY_MM, COUNT(*) AS "Active Users"
        FROM EventCube.Sessions a
        JOIN AuthDB_Applications b ON a.ApplicationId = b.ApplicationId
        WHERE b.StartDate < CURRENT_DATE
        AND b.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 month')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 month')||'-01 00:00:00' AS TIMESTAMP) --Past 13 Months
        GROUP BY 1
) active ON base.YYYY_MM = active.YYYY_MM

ORDER BY base.YYYY_MM DESC;

