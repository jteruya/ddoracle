--Identify all the Profile Views in the past 13 months
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_profileviews;
CREATE TABLE dashboard.kpi_social_metrics_profileviews AS
SELECT
Application_Id AS ApplicationId, Global_User_Id AS GlobalUserId, Metadata, CAST(Metadata ->> 'userid' AS TEXT) AS Metadata_UserId, Created, Binary_Version AS BinaryVersion
FROM PUBLIC.Fact_Views_Old
WHERE Identifier = 'profile'
AND Created >= CURRENT_DATE - INTERVAL'13 months'
AND CAST(Metadata ->> 'userid' AS TEXT) IS NOT NULL;

CREATE INDEX ndx_kpi_social_metrics_profileviews ON dashboard.kpi_social_metrics_profileviews (ApplicationId, GlobalUserId);

--Classify every Profile View
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_profileviews_classify;
CREATE TABLE dashboard.kpi_social_metrics_profileviews_classify AS
SELECT base.*, iu.UserId, CASE WHEN CAST(iu.UserId AS TEXT) <> CAST(base.Metadata_UserId AS TEXT) THEN 1 ELSE 0 END AS ElseProfileView_Ind
FROM dashboard.kpi_social_metrics_profileviews base
JOIN AuthDB_IS_Users iu ON base.ApplicationId = iu.ApplicationId AND base.GlobalUserId = iu.GlobalUserId;

--Get all Exhibitor Item Views
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_exhibitorview_users;
CREATE TABLE dashboard.kpi_social_metrics_exhibitorview_users AS
SELECT DISTINCT Application_Id AS ApplicationId, Global_User_Id AS GlobalUserId
FROM PUBLIC.Fact_Views_Old 
WHERE Identifier = 'item' 
AND Metadata ->> 'type' = 'exhibitor' 
AND Created >= CURRENT_DATE - INTERVAL'13 months';

CREATE INDEX ndx_kpi_social_metrics_exhibitorview_users ON dashboard.kpi_social_metrics_exhibitorview_users (ApplicationId,GlobalUserId);

--Identify per all active users whether they saw an Exhibitor Detail view (for apps with Exhibitor Items)
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_exhibitorviews;
CREATE TABLE dashboard.kpi_social_metrics_exhibitorviews AS
SELECT CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM,
app.ApplicationId,
iu.UserId,
CASE WHEN ex.GlobalUserId IS NOT NULL THEN 1 ELSE 0 END AS ViewExhibitor_Ind
FROM AuthDB_Applications app 
JOIN EventCube.Agg_Session_Per_AppUser agg ON app.ApplicationId = agg.ApplicationId --Only users that at least had a session in the app
JOIN AuthDB_IS_Users iu ON agg.UserId = iu.UserId
LEFT JOIN dashboard.kpi_social_metrics_exhibitorview_users ex ON iu.ApplicationId = ex.ApplicationId AND iu.GlobalUserId = ex.GlobalUserId
WHERE app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CURRENT_DATE - INTERVAL'7 months'
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents)
AND app.ApplicationId IN (SELECT DISTINCT i.ApplicationId FROM Ratings_Item i JOIN Ratings_Topic t ON i.ParentTopicId = t.TopicId WHERE t.ListTypeId = 3 AND i.IsDisabled = 0) --Only events with Exhibitor Items
;

--Identify all MenuItem taps
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps AS
SELECT ApplicationId, GlobalUserId,
CASE 
  WHEN LOWER(MenuItemListType) = 'agenda' THEN 'Agenda'
  WHEN LOWER(MenuItemListType) = 'regular' THEN 'List (Misc)'
  WHEN LOWER(MenuItemListType) = 'speakers' THEN 'Speakers'
  WHEN LOWER(MenuItemListType) = 'file' THEN 'Files'
  WHEN LOWER(MenuItemListType) = 'exhibitors' THEN 'Exhibitors'
  WHEN LOWER(MenuItemListType) = 'folder' THEN 'Folder'
  WHEN LOWER(MenuItemType) = 'list' AND MenuItemListType IS NULL THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) = 'topic' AND MenuItemListType IS NULL THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) = 'list' AND MenuItemListType = 'unspecified' THEN 'List (Unknown)'
  WHEN LOWER(MenuItemType) = 'listgroup' THEN 'List Group'
  WHEN LOWER(MenuItemType) = 'activities' THEN 'Activity Feed'
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
  WHEN LOWER(MenuItemType) = 'polls' THEN 'Polls'
  WHEN LOWER(MenuItemType) = 'profile' THEN 'Profile'
  WHEN LOWER(MenuItemType) = 'qrcodescanner' THEN 'QR Code Scanner'
  WHEN LOWER(MenuItemType) = 'surveys' THEN 'Surveys'
  WHEN LOWER(MenuItemType) = 'survey' THEN 'Survey'
  WHEN LOWER(MenuItemType) = 'switchevent' THEN 'Switch Event'
  WHEN LOWER(MenuItemType) = 'users' THEN 'Attendees'
  WHEN LOWER(MenuItemType) = 'web' THEN 'Web URL'
  ELSE '(N/A)'
END AS MenuItem,
MenuItemType,
MenuItemListType,
Created,
AppStartDate,
CAST(EXTRACT(YEAR FROM AppStartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM AppStartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM AppStartDate) AS INT) AS YYYY_MM
FROM (
SELECT 
a.Application_Id AS ApplicationId,
a.Global_User_Id AS GLobalUserId,
CAST(a.Metadata ->> 'type' AS TEXT) AS MenuItemType,
CAST(a.Metadata ->> 'listid' AS TEXT) AS MenuItemListId,
CAST(a.Metadata ->> 'listtype' AS TEXT) AS MenuItemListType,
a.Created,
app.StartDate AS AppStartDate
FROM PUBLIC.Fact_Actions_Old a
JOIN PUBLIC.AuthDB_Applications app ON a.Application_Id = app.ApplicationId
WHERE a.Identifier = 'menuitem'
AND app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CURRENT_DATE - INTERVAL'7 months'
AND a.Created >= CURRENT_DATE - INTERVAL'13 months'
AND a.Application_Id NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events
) t;

CREATE INDEX ndx_kpi_social_metrics_menuitemtaps_menuitem_dt ON dashboard.kpi_social_metrics_menuitemtaps (MenuItem, YYYY_MM);
CREATE INDEX ndx_kpi_social_metrics_menuitemtaps_appusercreated ON dashboard.kpi_social_metrics_menuitemtaps (ApplicationId,GlobalUserId,Created);
--CREATE INDEX ndx_kpi_social_metrics_menuitemtaps_appuserdtcreated ON dashboard.kpi_social_metrics_menuitemtaps (ApplicationId,GlobalUserId,YYYY_MM,Created);

--Menu Item Tap Percentages per month
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps_pct;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps_pct AS
SELECT * FROM (
SELECT DISTINCT
base.MenuItem, base.YYYY_MM, 
ROUND(100 * CAST(COUNT(*) OVER (PARTITION BY base.MenuItem, base.YYYY_MM) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY base.YYYY_MM) AS NUMERIC),2) AS PCT_MenuItemTaps
FROM dashboard.kpi_social_metrics_menuitemtaps base
) t WHERE PCT_MenuItemTaps >= 0.5; --Restrict to not include anything that never made it past 0.5%

--Identify the first N tapped MenuItem selections per User
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps_firstN;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps_firstN AS
SELECT *
FROM (
SELECT *, RANK() OVER (PARTITION BY ApplicationId, GlobalUserId, YYYY_MM ORDER BY Created ASC) AS RNK 
FROM dashboard.kpi_social_metrics_menuitemtaps base
) t
WHERE RNK <= 5;

--Per Month, what % of first Menu Item taps are for each selection choice?
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_menuitemtaps_1st_pct;
CREATE TABLE dashboard.kpi_social_metrics_menuitemtaps_1st_pct AS
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
ORDER BY 1,2