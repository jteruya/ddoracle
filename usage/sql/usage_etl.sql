--Identify all the Profile Views in the past 13 months
CREATE TEMPORARY TABLE kpi_social_metrics_profileviews TABLESPACE FastStorage AS
SELECT
ApplicationId, GlobalUserId, Metadata, CAST(Metadata ->> 'userid' AS TEXT) AS Metadata_UserId, Created, BinaryVersion AS BinaryVersion
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
SELECT DISTINCT ApplicationId, GlobalUserId
FROM PUBLIC.V_Fact_Views_All 
WHERE Identifier = 'item' 
AND Metadata ->> 'type' = 'exhibitor' 
AND Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
;

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

--Identify all MenuItem taps
--DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps;
CREATE TEMPORARY TABLE kpi_social_metrics_menuitemtaps TABLESPACE FastStorage AS
SELECT ApplicationId, GlobalUserId,
CASE 
  WHEN LOWER(MenuItemListType) = 'agenda' OR LOWER(MenuItemType) = 'agenda' THEN 'Agenda'
  WHEN LOWER(MenuItemListType) = 'regular' THEN 'List (Misc)'
  WHEN LOWER(MenuItemListType) = 'speakers' THEN 'Speakers'
  WHEN LOWER(MenuItemListType) = 'file' THEN 'Files'
  WHEN LOWER(MenuItemListType) = 'exhibitors' THEN 'Exhibitors'
  WHEN LOWER(MenuItemListType) = 'folder' THEN 'Folder'
  WHEN LOWER(MenuItemType) = 'list' AND MenuItemListType IS NULL THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) IN ('topic','topicinfo') AND MenuItemListType IS NULL THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) = 'list' AND MenuItemListType = 'unspecified' THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) IN ('listgroup','subjects') THEN 'List Group'
  WHEN LOWER(MenuItemType) IN ('activities','activityfeed') THEN 'Activity Feed'
  WHEN LOWER(MenuItemType) = 'activity' THEN 'Activity Card'
  WHEN LOWER(MenuItemType) IN ('bookmarks','favorites') THEN 'Bookmarks'
  WHEN LOWER(MenuItemType) = 'chats' THEN 'Chats'
  WHEN LOWER(MenuItemType) = 'following' THEN 'Following'
  WHEN LOWER(MenuItemType) = 'globalsearch' THEN 'Search'
  WHEN LOWER(MenuItemType) = 'item' THEN 'Item Detail'
  WHEN LOWER(MenuItemType) = 'leaderboard' THEN 'Leaderboard'
  WHEN LOWER(MenuItemType) = 'leads' THEN 'Leads'
  WHEN LOWER(MenuItemType) = 'map' THEN 'Interactive Map'
  WHEN LOWER(MenuItemType) = 'notifications' THEN 'Notifications'
  WHEN LOWER(MenuItemType) = 'photofeed' THEN 'Photofeed'
  WHEN LOWER(MenuItemType) IN ('polls','poll') THEN 'Polls'
  WHEN LOWER(MenuItemType) = 'profile' THEN 'Profile'
  WHEN LOWER(MenuItemType) = 'qrcodescanner' THEN 'QR Code Scanner'
  WHEN LOWER(MenuItemType) = 'surveys' THEN 'Surveys'
  WHEN LOWER(MenuItemType) = 'survey' THEN 'Survey'
  WHEN LOWER(MenuItemType) = 'switchevent' THEN 'Switch Event'
  WHEN LOWER(MenuItemType) = 'users' THEN 'Attendees'
  WHEN LOWER(MenuItemType) = 'web' THEN 'Web URL'
  WHEN LOWER(MenuItemType) = 'badges' THEN 'Badges'
  WHEN LOWER(MenuItemType) = 'settings' THEN 'Settings'
  WHEN LOWER(MenuItemType) = 'hashtagfeed' THEN 'Hashtag Feed'
  ELSE '(N/A)'
END AS MenuItem,
MenuItemType,
MenuItemListType,
Created,
AppStartDate,
CAST(EXTRACT(YEAR FROM AppStartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM AppStartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM AppStartDate) AS INT) AS YYYY_MM
FROM (
SELECT 
a.ApplicationId,
a.GlobalUserId,
CAST(a.Metadata ->> 'type' AS TEXT) AS MenuItemType,
CAST(a.Metadata ->> 'listid' AS TEXT) AS MenuItemListId,
CAST(a.Metadata ->> 'listtype' AS TEXT) AS MenuItemListType,
a.Created,
app.StartDate AS AppStartDate
FROM PUBLIC.V_Fact_Actions_All a
JOIN PUBLIC.AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
WHERE a.Identifier = 'menuitem'
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'7 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'7 months')||'-01 00:00:00' AS TIMESTAMP) --Past 7 months
AND a.Created >= CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL'13 months')||'-'||EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL'13 months')||'-01 00:00:00' AS TIMESTAMP) --Past 13 months
AND a.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events
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

--Identify the breakdown on Menu Item taps at the Event Level
DROP TABLE IF EXISTS Event_MenuItemTaps;
CREATE TEMPORARY TABLE Event_MenuItemTaps TABLESPACE FastStorage AS 
SELECT a.ApplicationId,
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
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('item') THEN CAST(a.Metadata ->> 'itemid' AS TEXT) END AS ItemId,
CASE WHEN LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('list') THEN CAST(a.Metadata ->> 'listid' AS TEXT) END AS ListId
FROM V_Fact_Actions_All a
JOIN AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
WHERE a.Identifier = 'menuitem'
AND a.ApplicationId IN (
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

