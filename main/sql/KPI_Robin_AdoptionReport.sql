SELECT EventType, YYYY_MM, PCT_Adoption 

FROM (

SELECT EventType, YYYY_MM, 100.00 * ROUND((1 / CAST(COUNT(*) AS NUMERIC)) * SUM(PCT_Adoption),2) AS PCT_Adoption

FROM (

--Full List of all Closed Registration Events and their Adoption Rates
SELECT ApplicationId, Name, StartDate, 
CASE WHEN sfdc.sf_bm_event_type__c = 'Conference (>2:1 session:exhibitor ratio)' THEN 'Conference' WHEN sfdc.sf_bm_event_type__c = 'Corporate External' THEN 'Corporate External' WHEN sfdc.sf_bm_event_type__c = 'Corporate Internal' THEN 'Corporate Internal' WHEN sfdc.sf_bm_event_type__c = 'Expo (<2:1 session:exhibitor ratio)' THEN 'Expo' WHEN (sfdc.sf_bm_event_type__c = 'None' OR sfdc.sf_bm_event_type__c IS NULL) THEN CASE WHEN t.EventType = 'Conference (>2:1 session:exhibitor ratio)' THEN 'Conference' WHEN t.EventType = 'Corporate External' THEN 'Corporate External' WHEN t.EventType = 'Corporate Internal' THEN 'Corporate Internal' WHEN t.EventType = 'Expo (<2:1 session:exhibitor ratio)' THEN 'Expo' ELSE 'N/A' END END AS EventType,
CAST(EXTRACT(YEAR FROM StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM StartDate) AS INT) AS YYYY_MM,
COUNT(*) AS ListedUsers, SUM(ActiveUserInd) AS ActiveListedUsers, 
CAST(SUM(ActiveUserInd) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Adoption
FROM (

--Full List of all Attendees per Event and flags to indicate if they had a Session
SELECT app.ApplicationId, app.Name, app.EventType, CAST(app.StartDate AS Date) AS StartDate, u.UserId, CASE WHEN aspa.UserId IS NOT NULL THEN 1 ELSE 0 END AS ActiveUserInd
FROM AuthDB_Applications app
JOIN AuthDB_IS_Users u ON app.ApplicationId = u.ApplicationId
LEFT JOIN EventCube.Agg_Session_Per_AppUser aspa ON app.ApplicationId = aspa.ApplicationId AND u.UserId = aspa.UserId --List of Users with a Session per Application
WHERE app.CanRegister = 'false' --Closed Reg Events
AND u.IsDisabled = 0 --Only existing Attendees in the list
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Filter out Test Events

) t 
LEFT JOIN kevin.sf_implementation__c sfdc ON t.ApplicationId = sfdc.sf_event_id_cms__c
WHERE StartDate <= CURRENT_DATE --Only Events that have already started
AND StartDate >= CURRENT_DATE - INTERVAL'13 months'
GROUP BY 1,2,3,4

) t 
GROUP BY 1,2

UNION ALL

--Get the overall Adoption %
SELECT base.EventType AS EventType, base.YYYY_MM, 100.00 * ROUND(MEDIAN(PCT_Adoption),2) AS PCT_Adoption

FROM (

--Full List of all Closed Registration Events and their Adoption Rates
SELECT ApplicationId, Name, StartDate, 'All Events' AS EventType,
CAST(EXTRACT(YEAR FROM StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM StartDate) AS INT) AS YYYY_MM,
COUNT(*) AS ListedUsers, SUM(ActiveUserInd) AS ActiveListedUsers, 
CAST(SUM(ActiveUserInd) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_Adoption
FROM (

--Full List of all Attendees per Event and flags to indicate if they had a Session
SELECT app.ApplicationId, app.Name, app.EventType, CAST(app.StartDate AS Date) AS StartDate, u.UserId, CASE WHEN aspa.UserId IS NOT NULL THEN 1 ELSE 0 END AS ActiveUserInd
FROM AuthDB_Applications app
JOIN AuthDB_IS_Users u ON app.ApplicationId = u.ApplicationId
LEFT JOIN EventCube.Agg_Session_Per_AppUser aspa ON app.ApplicationId = aspa.ApplicationId AND u.UserId = aspa.UserId --List of Users with a Session per Application
WHERE app.CanRegister = 'false' --Closed Reg Events
AND u.IsDisabled = 0 --Only existing Attendees in the list
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Filter out Test Events

) t 
WHERE StartDate <= CURRENT_DATE --Only Events that have already started
AND StartDate >= CURRENT_DATE - INTERVAL'13 months'
GROUP BY 1,2,3,4

) base

GROUP BY 1,2 

) t 
WHERE EventType <> 'N/A'
ORDER BY 1,2