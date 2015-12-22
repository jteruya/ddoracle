--Identify all the Profile Views in the past 13 months
CREATE TEMPORARY TABLE kpi_social_metrics_profileviews TABLESPACE FastStorage AS
SELECT
Src, ApplicationId, GlobalUserId, Metadata, CAST(Metadata ->> 'userid' AS TEXT) AS Metadata_UserId, Created, BinaryVersion AS BinaryVersion
FROM PUBLIC.V_Fact_Views_All
WHERE Identifier = 'profile'
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND CAST(Metadata ->> 'userid' AS TEXT) IS NOT NULL;

CREATE INDEX ndx_kpi_social_metrics_profileviews ON kpi_social_metrics_profileviews (ApplicationId, GlobalUserId) TABLESPACE FastStorage;

--Classify every Profile View
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_profileviews_classify;
CREATE TABLE dashboard.kpi_social_metrics_profileviews_classify TABLESPACE FastStorage AS
SELECT base.*, iu.UserId, CASE WHEN CAST(iu.UserId AS TEXT) <> CAST(base.Metadata_UserId AS TEXT) THEN 1 ELSE 0 END AS ElseProfileView_Ind
FROM kpi_social_metrics_profileviews base
JOIN AuthDB_IS_Users iu ON base.ApplicationId = iu.ApplicationId AND base.GlobalUserId = iu.GlobalUserId;

--Get all Exhibitor Item Views
CREATE TEMPORARY TABLE kpi_social_metrics_exhibitorview_users TABLESPACE FastStorage AS
--Robin Historical
SELECT DISTINCT UPPER(Application_Id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId
FROM PUBLIC.Fact_Views_Old
WHERE Created < '2015-04-24 00:00:00'
AND (Identifier = 'item' AND Metadata ->> 'type' = 'exhibitor') OR (Identifier IN ('exhibitorprofile'))
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
UNION
--Alfred
SELECT DISTINCT UPPER(Application_Id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId
FROM PUBLIC.Fact_Views
WHERE Created >= '2015-04-24 00:00:00'
AND (Identifier = 'item' AND Metadata ->> 'type' = 'exhibitor') OR (Identifier IN ('exhibitorprofile'))
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
UNION 
--oldMetrics Live
SELECT DISTINCT UPPER(Application_Id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId
FROM PUBLIC.Fact_Views_New
WHERE (Identifier = 'item' AND Metadata ->> 'type' = 'exhibitor') OR (Identifier IN ('exhibitorprofile'))
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
UNION
--newMetrics Live
SELECT DISTINCT UPPER(Application_Id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId
FROM PUBLIC.Fact_Views_Live
WHERE Identifier = 'item'
AND CAST(Metadata ->> 'ListId' AS INT) IN (SELECT t.TopicId FROM Ratings_Topic t WHERE t.ListTypeId = 3)
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND Application_Id IS NOT NULL AND Global_User_Id IS NOT NULL;

CREATE INDEX ndx_kpi_social_metrics_exhibitorview_users ON kpi_social_metrics_exhibitorview_users (ApplicationId,GlobalUserId) TABLESPACE FastStorage;

--Identify per all active users whether they saw an Exhibitor Detail view (for apps with Exhibitor Items)
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_exhibitorviews;
CREATE TABLE dashboard.kpi_social_metrics_exhibitorviews TABLESPACE FastStorage AS
SELECT CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM,
app.ApplicationId,
iu.UserId,
CASE WHEN ex.GlobalUserId IS NOT NULL THEN 1 ELSE 0 END AS ViewExhibitor_Ind
FROM AuthDB_Applications app 
JOIN EventCube.Agg_Session_Per_AppUser agg ON app.ApplicationId = agg.ApplicationId --Only users that at least had a session in the app
JOIN AuthDB_IS_Users iu ON agg.UserId = iu.UserId
LEFT JOIN kpi_social_metrics_exhibitorview_users ex ON iu.ApplicationId = ex.ApplicationId AND iu.GlobalUserId = ex.GlobalUserId
WHERE app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND app.ApplicationId IN (SELECT DISTINCT i.ApplicationId FROM Ratings_Item i JOIN Ratings_Topic t ON i.ParentTopicId = t.TopicId WHERE t.ListTypeId = 3 AND i.IsDisabled = 0) --Only events with Exhibitor Items
;

--================================================================================================================================================================

--Identify all MenuItem taps
--DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps;
CREATE TEMPORARY TABLE kpi_social_metrics_menuitemtaps TABLESPACE FastStorage AS
SELECT ApplicationId, GlobalUserId,
CASE 
  WHEN LOWER(MenuItemListType) = 'agenda' OR LOWER(MenuItemType) = 'agenda' OR LOWER(MenuItemUrl) LIKE  '%://agenda%' THEN 'Agenda'
  WHEN LOWER(MenuItemListType) = 'regular' THEN 'List (Misc)'
  WHEN LOWER(MenuItemListType) = 'speakers' THEN 'Speakers'
  WHEN LOWER(MenuItemListType) = 'file' THEN 'Files'
  WHEN LOWER(MenuItemListType) = 'exhibitors' THEN 'Exhibitors'
  WHEN LOWER(MenuItemListType) = 'folder' THEN 'Folder'
  WHEN LOWER(MenuItemType) = 'list' AND MenuItemListType IS NULL THEN 'List (Unknown)'
  WHEN (LOWER(MenuItemType) IN ('topic','topicinfo') AND MenuItemListType IS NULL) THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) = 'list' AND MenuItemListType = 'unspecified' THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) IN ('listgroup','subjects')  OR LOWER(MenuItemUrl) LIKE '%://subjects%' THEN 'List Group'
  WHEN LOWER(MenuItemType) IN ('activities','activityfeed') OR LOWER(MenuItemUrl) LIKE '%://activityfeed%' THEN 'Activity Feed'
  WHEN LOWER(MenuItemType) = 'activity' THEN 'Activity Card'
  WHEN LOWER(MenuItemType) IN ('bookmarks','favorites')  OR LOWER(MenuItemUrl) LIKE '%://favorites%' THEN 'Bookmarks'
  WHEN LOWER(MenuItemType) = 'chats' OR LOWER(MenuItemUrl) LIKE '%://messages%'THEN 'Chats'
  WHEN LOWER(MenuItemType) = 'following' THEN 'Following'
  WHEN LOWER(MenuItemType) = 'globalsearch'  OR LOWER(MenuItemUrl) LIKE '%://globalsearch%' THEN 'Search'
  WHEN LOWER(MenuItemType) = 'item' OR LOWER(MenuItemUrl) LIKE '%://item%' THEN 'Item Detail'
  WHEN LOWER(MenuItemType) = 'leaderboard' OR LOWER(MenuItemUrl) LIKE '%://leaderboard%' THEN 'Leaderboard'
  WHEN LOWER(MenuItemType) = 'leads' OR LOWER(MenuItemUrl) LIKE '%://leads%' THEN 'Leads'
  WHEN LOWER(MenuItemType) = 'map' OR LOWER(MenuItemUrl) LIKE '%://map%' THEN 'Interactive Map'
  WHEN LOWER(MenuItemType) = 'notifications' THEN 'Notifications'
  WHEN LOWER(MenuItemType) = 'photofeed'  OR LOWER(MenuItemUrl) LIKE '%://photofeed%' THEN 'Photofeed'
  WHEN LOWER(MenuItemType) IN ('polls','poll')  OR LOWER(MenuItemUrl) LIKE '%://poll%' THEN 'Polls'
  WHEN LOWER(MenuItemType) = 'profile' OR LOWER(MenuItemUrl) LIKE '%://profile%' THEN 'Profile'
  WHEN LOWER(MenuItemType) = 'qrcodescanner'  OR LOWER(MenuItemUrl) LIKE '%://qrcodescanner%' THEN 'QR Code Scanner'
  WHEN LOWER(MenuItemType) = 'surveys'  OR LOWER(MenuItemUrl) LIKE '%://survey%' THEN 'Surveys'
  WHEN LOWER(MenuItemType) = 'survey' THEN 'Survey'
  WHEN LOWER(MenuItemType) = 'switchevent' OR LOWER(MenuItemUrl) LIKE '%://switchevent%' THEN 'Switch Event'
  WHEN LOWER(MenuItemType) = 'users'  OR LOWER(MenuItemUrl) LIKE '%://users%' THEN 'Attendees'
  WHEN LOWER(MenuItemType) = 'web'  OR LOWER(MenuItemUrl) LIKE 'http%' THEN 'Web URL'
  WHEN LOWER(MenuItemType) = 'badges' OR LOWER(MenuItemUrl) LIKE '%://badges%' THEN 'Badges'
  WHEN LOWER(MenuItemType) = 'settings'  OR LOWER(MenuItemUrl) LIKE '%://settings%' THEN 'Settings'
  WHEN LOWER(MenuItemType) = 'hashtagfeed' THEN 'Hashtag Feed'
  WHEN LOWER(MenuItemUrl) LIKE '%://update%' THEN 'Update'
  ELSE '(N/A)'
END AS MenuItem,
MenuItemType,
MenuItemListType,
Created,
AppStartDate,
CAST(EXTRACT(YEAR FROM AppStartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM AppStartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM AppStartDate) AS INT) AS YYYY_MM
FROM (

--oldMetrics (ALL)
SELECT 
a.ApplicationId,
a.GlobalUserId,
a.Metadata,
CAST(a.Metadata ->> 'type' AS TEXT) AS MenuItemType,
CAST(a.Metadata ->> 'listid' AS TEXT) AS MenuItemListId,
CAST(a.Metadata ->> 'listtype' AS TEXT) AS MenuItemListType,
CAST(a.Metadata ->> 'Url' AS TEXT) AS MenuItemURL,
a.Created,
app.StartDate AS AppStartDate
FROM PUBLIC.V_Fact_Actions_All a
JOIN PUBLIC.AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
WHERE a.SRC NOT IN ('New_Metrics')
AND a.Identifier IN ('menuitem')
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND a.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events

UNION ALL

--newMetrics (non-List)
SELECT 
a.ApplicationId,
a.GlobalUserId,
a.Metadata,
CAST(a.Metadata ->> 'type' AS TEXT) AS MenuItemType,
CAST(a.Metadata ->> 'listid' AS TEXT) AS MenuItemListId,
CAST(a.Metadata ->> 'listtype' AS TEXT) AS MenuItemListType,
CAST(a.Metadata ->> 'Url' AS TEXT) AS MenuItemURL,
a.Created,
app.StartDate AS AppStartDate
FROM PUBLIC.V_Fact_Actions_All a
JOIN PUBLIC.AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
WHERE a.SRC IN ('New_Metrics')
AND a.Identifier IN ('menuItem')
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND a.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events
AND CAST(a.Metadata ->> 'Url' AS TEXT) NOT LIKE '%://topic%'

UNION ALL

--newMetrics (List)
SELECT 
a.ApplicationId,
a.GlobalUserId,
a.Metadata,
CAST(NULL AS TEXT) AS MenuItemType,
REPLACE(REPLACE(CAST(a.Metadata ->> 'Url' AS TEXT),'dd://topic/',''),'dd://topicinfo/','') AS MenuItemListId,
CASE WHEN t.ListTypeId = 1 THEN 'regular' WHEN t.ListTypeId = 3 THEN 'exhibitors' WHEN t.ListTypeId = 4 THEN 'speakers' WHEN t.ListTypeId = 5 THEN 'folder' END AS MenuItemListType,
CAST(a.Metadata ->> 'Url' AS TEXT) AS MenuItemURL,
a.Created,
app.StartDate AS AppStartDate
FROM PUBLIC.V_Fact_Actions_All a
JOIN PUBLIC.AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
LEFT JOIN Ratings_Topic t ON CAST(REPLACE(REPLACE(CAST(a.Metadata ->> 'Url' AS TEXT),'dd://topic/',''),'dd://topicinfo/','') AS INT) = t.TopicId
WHERE a.SRC IN ('New_Metrics')
AND a.Identifier IN ('menuItem')
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND a.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events
AND CAST(a.Metadata ->> 'Url' AS TEXT) LIKE '%://topic%'

) t;

--CREATE INDEX ndx_kpi_social_metrics_menuitemtaps_menuitem_dt ON dashboard.kpi_social_metrics_menuitemtaps (MenuItem, YYYY_MM) TABLESPACE FastStorage;
--CREATE INDEX ndx_kpi_social_metrics_menuitemtaps_appusercreated ON dashboard.kpi_social_metrics_menuitemtaps (ApplicationId,GlobalUserId,Created) TABLESPACE FastStorage;
--CREATE INDEX ndx_kpi_social_metrics_menuitemtaps_appuserdtcreated ON dashboard.kpi_social_metrics_menuitemtaps (ApplicationId,GlobalUserId,YYYY_MM,Created);

--Menu Item Tap Percentages per month
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps_pct;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps_pct TABLESPACE FastStorage AS
SELECT * FROM (
SELECT DISTINCT
base.MenuItem, base.YYYY_MM, 
ROUND(100 * CAST(COUNT(*) OVER (PARTITION BY base.MenuItem, base.YYYY_MM) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY base.YYYY_MM) AS NUMERIC),2) AS PCT_MenuItemTaps
FROM kpi_social_metrics_menuitemtaps base
) t WHERE PCT_MenuItemTaps >= 0.5; --Restrict to not include anything that never made it past 0.5%

--Identify the first N tapped MenuItem selections per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps_firstN;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps_firstN TABLESPACE FastStorage AS
SELECT *
FROM (
SELECT *, RANK() OVER (PARTITION BY ApplicationId, GlobalUserId, YYYY_MM ORDER BY Created ASC) AS RNK 
FROM kpi_social_metrics_menuitemtaps base
) t
WHERE RNK <= 5;

--Per Month, what % of first Menu Item taps are for each selection choice?
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps_1st_pct;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps_1st_pct TABLESPACE FastStorage AS
SELECT MenuItem, YYYY_MM, PCT_MenuItem
FROM (
SELECT DISTINCT YYYY_MM, MenuItem, 
--SUM(1) OVER (PARTITION BY YYYY_MM) AS TotalTaps, 
--COUNT(*) OVER (PARTITION BY YYYY_MM, MenuItem) AS Count_MenuItemTaps,
ROUND(100 * CAST(COUNT(*) OVER (PARTITION BY YYYY_MM, MenuItem) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY YYYY_MM) AS NUMERIC),2) AS PCT_MenuItem
FROM dashboard.kpi_social_metrics_menuitemtaps_firstN
WHERE RNK = 1 --Only care about the first tap
) t 
WHERE t.PCT_MenuItem >= 0.5 --Minimum 0.5% of taps, otherwise not shown
ORDER BY 1,2;

--================================================================================================================================================================

--Identify the breakdown on Menu Item taps at the Event Level
DROP TABLE IF EXISTS Event_MenuItemTaps;
CREATE TEMPORARY TABLE Event_MenuItemTaps TABLESPACE FastStorage AS 
SELECT a.ApplicationId, a.Tapped, a.URL, a.ItemId, a.ListId

FROM (
-- Old Metrics Case
SELECT a.ApplicationId, a.Created,
CASE
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('activities','activityfeed') THEN 'Activity Feed'
  WHEN LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'agenda' OR LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) = 'agenda' THEN 'Agenda'
  WHEN LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'speakers' THEN 'Speakers'
  WHEN LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'exhibitors' THEN 'Exhibitors'
  WHEN LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'folder' THEN 'Folder'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) = 'users' THEN 'Attendees'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('surveys') THEN 'Surveys'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('leaderboard') THEN 'Leaderboard'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('photofeed') THEN 'Photofeed'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('map') THEN 'Map'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('url') THEN 'Web View'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('item') THEN 'Item'
  WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('switchevent') THEN 'Switch Event'
  ELSE 'Other'
END AS Tapped,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('url') THEN CAST(a.Metadata ->> 'url' AS TEXT) END AS URL,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('item') THEN CAST(a.Metadata ->> 'itemid' AS TEXT) WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://item%' THEN REPLACE(CAST(a.Metadata ->> 'Url' AS TEXT),'dd://item/','') END AS ItemId,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('list') THEN CAST(a.Metadata ->> 'listid' AS TEXT) END AS ListId
FROM V_Fact_Actions_All a
WHERE a.SRC NOT IN ('New_Metrics')
AND a.Identifier IN ('menuitem')

UNION ALL

-- New Metrics Case (Non-List)
SELECT a.ApplicationId, a.Created,
CASE
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://activityfeed%' THEN 'Activity Feed'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://agenda%' THEN 'Agenda'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://users%' THEN 'Attendees'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://survey%' THEN 'Surveys'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://leaderboard%' THEN 'Leaderboard'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://photofeed%' THEN 'Photofeed'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://map%' THEN 'Map'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE 'http%'THEN 'Web View'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://item%' THEN 'Item'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://switchevent%' THEN 'Switch Event'
  WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://poll%' THEN 'Polls'
  ELSE 'Other'
END AS Tapped,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('url') THEN CAST(a.Metadata ->> 'url' AS TEXT) END AS URL,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('item') THEN CAST(a.Metadata ->> 'itemid' AS TEXT) WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://item%' THEN REPLACE(CAST(a.Metadata ->> 'Url' AS TEXT),'dd://item/','') END AS ItemId,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('list') THEN CAST(a.Metadata ->> 'listid' AS TEXT) END AS ListId
FROM V_Fact_Actions_All a
WHERE a.SRC IN ('New_Metrics')
AND a.Identifier IN ('menuItem')
AND LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) NOT LIKE '%://topic%'

UNION ALL

-- New Metrics Case (Lists)
SELECT a.ApplicationId, a.Created,
CASE
  WHEN t.ListTypeId = 4 THEN 'Speakers'
  WHEN t.ListTypeId = 3 THEN 'Exhibitors'
  WHEN t.ListTypeId = 5 THEN 'Folder'
  ELSE 'Other'
END AS Tapped,
CAST(NULL AS TEXT) AS URL,
CAST(NULL AS TEXT) AS ItemId,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('list') THEN CAST(a.Metadata ->> 'listid' AS TEXT) WHEN LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://topic%' THEN REPLACE(REPLACE(CAST(a.Metadata ->> 'Url' AS TEXT),'dd://topic/',''),'dd://topicinfo/','') END AS ListId
FROM V_Fact_Actions_All a
LEFT JOIN Ratings_Topic t ON CAST(REPLACE(REPLACE(CAST(a.Metadata ->> 'Url' AS TEXT),'dd://topic/',''),'dd://topicinfo/','') AS INT) = t.TopicId
WHERE a.SRC IN ('New_Metrics')
AND a.Identifier IN ('menuItem')
AND LOWER(CAST(a.Metadata ->> 'Url' AS TEXT)) LIKE '%://topic%'
) a
JOIN AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
WHERE a.ApplicationId IN (
        SELECT A.ApplicationId FROM AuthDB_Applications A
        JOIN PUBLIC.AuthDB_Bundles B ON A.BundleId = B.BundleId
        WHERE StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'1 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'1 months')||'-01 00:00:00' AS TIMESTAMP) --Past 4 months
        --== Static Test Event filters
        AND A.Name NOT LIKE '%DoubleDutch%' AND B.Name NOT LIKE '%DoubleDutch%' AND UPPER(B.Name) NOT IN ('PRIDE','DDQA')
        AND A.BundleId NOT IN ('00000000-0000-0000-0000-000000000000','025AA15B-CE74-40AA-A4CC-04028401C8B3','89FD8F03-0D59-41AB-A6A7-2237D8AC4EB2','5A46600A-156A-441E-B594-40F7DEFB54F2','F95FE4A7-E86A-4661-AC59-8B423F1F540A','34B4E501-3F31-46A0-8F2A-0FB6EA5E4357','09E25995-8D8F-4C2D-8F55-15BA22595E11','5637BE65-6E3F-4095-BEB8-115849B5584A','9F3489D7-C93C-4C8B-8603-DDA6A9061116','D0F56154-E8E7-4566-A845-D3F47B8B35CC','BC35D4CE-C571-4F91-834A-A8136CA137C4','3E3FDA3D-A606-4013-8DDF-711A1871BD12','75CE91A5-BCC0-459A-B479-B3956EA09ABC','384D052E-0ABD-44D1-A643-BC590135F5A0','B752A5B3-AA53-4BCF-9F52-D5600474D198','15740A5A-25D8-4DC6-A9ED-7F610FF94085','0CBC9D00-1E6D-4DB3-95FC-C5FBB156C6DE','F0C4B2DB-A743-4FB2-9E8F-A80463E52B55','8A995A58-C574-421B-8F82-E3425D9054B0','6DBB91C8-6544-48EF-8B8D-A01B435F3757','F21325D8-3A43-4275-A8B8-B4B6E3F62DE0','DE8D1832-B4EA-4BD2-AB4B-732321328B04','7E289A59-E573-454C-825B-CF31B74C8506')
) 
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'1 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'1 months')||'-01 00:00:00' AS TIMESTAMP) --Past 1 months
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'3 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'3 months')||'-01 00:00:00' AS TIMESTAMP) --Past 3 months
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
;

--By event, break down the counts on different Menu Items and identify their % of the total
DROP TABLE IF EXISTS dashboard.kpi_event_menutapspct;
CREATE TABLE dashboard.kpi_event_menutapspct AS
SELECT DISTINCT base.ApplicationId, app.Name, Tapped, COUNT(*) OVER (PARTITION BY base.ApplicationId, Tapped) AS Taps, SUM(1) OVER (PARTITION BY base.ApplicationId) AS TotalTaps, 100 * CAST(COUNT(*) OVER (PARTITION BY base.ApplicationId, Tapped) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY base.ApplicationId) AS NUMERIC) AS PCT_Taps
FROM (
        SELECT  m.ApplicationId, 
                CASE 
                  WHEN m.Tapped = 'Item' THEN CASE WHEN m.ItemId IS NOT NULL THEN 'Item ('||REPLACE(i.Name,',','')||')' ELSE 'Other' END 
                  WHEN m.Tapped = 'Folder' THEN CASE WHEN m.ListId IS NOT NULL THEN 'Folder ('||REPLACE(t.Name,',','')||')' ELSE 'Other' END 
                  WHEN m.Tapped = 'URL' THEN CASE WHEN m.URL IS NOT NULL THEN 'URL ('||REPLACE(m.URL,',','')||')' ELSE 'Other' END 
                  ELSE m.Tapped 
                END AS Tapped 
        FROM Event_MenuItemTaps m
        LEFT JOIN Ratings_Item i ON CAST(m.ItemId AS INT) = i.ItemId 
        LEFT JOIN Ratings_Topic t ON CAST(m.ListId AS INT) = t.TopicId 
        WHERE m.Tapped IN ('Item','Folder','URL')
        UNION ALL
        SELECT ApplicationId, Tapped FROM Event_MenuItemTaps WHERE Tapped NOT IN ('Item','Folder','URL')
) base
JOIN AuthDB_Applications app ON base.ApplicationId = app.ApplicationId
ORDER BY 1,5 DESC;

--Identify the top 10 Menu Items selected per Event
DROP TABLE IF EXISTS dashboard.kpi_event_menutap_top;
CREATE TABLE dashboard.kpi_event_menutap_top AS 
SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY ApplicationId ORDER BY PCT_Taps DESC, Tapped DESC) AS RNK FROM dashboard.kpi_event_menutapspct) t WHERE RNK <= 10;

--================================================================================================================================================================

--== Satisfaction Card Usage
DROP TABLE IF EXISTS dashboard.SatisfactionCard_Events;
CREATE TABLE dashboard.SatisfactionCard_Events AS
SELECT app.ApplicationId, app.Name, app.StartDate, app.EndDate, sc.SatisfactionCard_Ind,
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM 
FROM AuthDB_Applications app
LEFT JOIN (SELECT ApplicationId, CAST(Metadata ->> 'send_satisfaction_card' AS BOOL) AS SatisfactionCard_Ind  FROM PUBLIC.ActivityFeedService) sc ON app.ApplicationId = sc.ApplicationId
WHERE app.StartDate >= '2015-07-01'
AND app.StartDate <= CURRENT_DATE
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents);

--1. Identify the set of all Impressions
DROP TABLE IF EXISTS dashboard.SatisfactionCard_Impressions;
CREATE TABLE dashboard.SatisfactionCard_Impressions AS
SELECT Created, UPPER(Application_id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, CASE WHEN App_Type_Id IN (1,2) THEN 'ios' WHEN App_Type_Id = 3 THEN 'android' END AS DeviceType FROM PUBLIC.Fact_Impressions WHERE Identifier = 'satisfactioncard' UNION ALL
SELECT Created, UPPER(Application_id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, CASE WHEN App_Type_Id IN (1,2) THEN 'ios' WHEN App_Type_Id = 3 THEN 'android' END AS DeviceType FROM PUBLIC.Fact_Impressions_New WHERE Identifier = 'satisfactioncard' UNION ALL
SELECT Created, UPPER(Application_id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, Device_Type AS DeviceType FROM PUBLIC.Fact_Impressions_Live WHERE Identifier = 'satisfactionCard';

CREATE INDEX ndx_satisfactioncard_impressions ON dashboard.SatisfactionCard_Impressions (ApplicationId);

--2. Identify the set of all Actions
DROP TABLE IF EXISTS dashboard.SatisfactionCard_Actions;
CREATE TABLE dashboard.SatisfactionCard_Actions AS
SELECT Created, UPPER(Application_id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, CASE WHEN App_Type_Id IN (1,2) THEN 'ios' WHEN App_Type_Id = 3 THEN 'android' END AS DeviceType, Metadata FROM PUBLIC.Fact_Actions WHERE Identifier = 'satisfactionbutton' UNION ALL
SELECT Created, UPPER(Application_id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, CASE WHEN App_Type_Id IN (1,2) THEN 'ios' WHEN App_Type_Id = 3 THEN 'android' END AS DeviceType, Metadata FROM PUBLIC.Fact_Actions_New WHERE Identifier = 'satisfactionbutton' UNION ALL
SELECT Created, UPPER(Application_id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, Device_Type AS DeviceType, Metadata FROM PUBLIC.Fact_Actions_Live WHERE Identifier = 'satisfactionButton';

CREATE INDEX ndx_satisfactioncard_actions ON dashboard.SatisfactionCard_Actions (ApplicationId);

--3. Identify the set of Attendees per Event and flag based on tracking
DROP TABLE IF EXISTS dashboard.SatisfactionCard_Attendees;
CREATE TABLE dashboard.SatisfactionCard_Attendees AS
SELECT app.ApplicationId, app.Name, app.YYYY_MM, app.SatisfactionCard_Ind, u.UserId, iu.GlobalUserId,
--Flag at the Attendee Level
CASE WHEN i.GlobalUserId IS NOT NULL THEN 1 ELSE 0 END AS Impression_Ind,
CASE WHEN t.GlobalUserId IS NOT NULL THEN 1 ELSE 0 END AS Tap_Ind
FROM dashboard.SatisfactionCard_Events app
JOIN EventCube.Agg_Session_per_AppUser u ON app.ApplicationId = u.ApplicationId
JOIN AuthDB_IS_Users iu ON u.UserId = iu.UserId
LEFT JOIN (SELECT DISTINCT ApplicationId, GlobalUserId FROM dashboard.SatisfactionCard_Impressions) i ON app.ApplicationId = i.ApplicationId AND iu.GlobalUserId = i.GlobalUserId
LEFT JOIN (SELECT DISTINCT ApplicationId, GlobalUserId FROM dashboard.SatisfactionCard_Actions) t ON app.ApplicationId = t.ApplicationId AND iu.GlobalUserId = t.GlobalUserId
WHERE app.SatisfactionCard_Ind = 'true' --Events with Satisfaction Card feature turned ON
AND iu.IsDisabled = 0 --Actual Attendees not flagged OFF
;