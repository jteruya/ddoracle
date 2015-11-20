--Identify the breakdown on all relevant action taps at the Event Level
DROP TABLE IF EXISTS Event_Taps;
CREATE TEMPORARY TABLE Event_Taps TABLESPACE FastStorage AS 

--oldMetrics
SELECT a.ApplicationId,
CASE
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('activities','activityfeed') THEN 'Menu - Activity Feed'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'agenda' OR LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) = 'agenda' THEN 'Menu - Agenda'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'speakers' THEN 'Menu - Speakers'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'exhibitors' THEN 'Menu - Exhibitors'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'listtype' AS TEXT)) = 'folder' THEN 'Menu - Folder'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) = 'users' THEN 'Menu - Attendees'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('surveys') THEN 'Menu - Surveys'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('poll','polls') THEN 'Menu - Polls'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('leaderboard') THEN 'Menu - Leaderboard'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('photofeed') THEN 'Menu - Photofeed'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('map') THEN 'Menu - Map'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('url','web') THEN 'Menu - Web View'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('item','topicinfo') THEN 'Menu - Item'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('list','topic') THEN 'Menu - List'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('switchevent') THEN 'Menu - Switch Event'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('bookmarks') THEN 'Menu - Bookmarks'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('qrcodescanner') THEN 'Menu - QR Code Scanner'
  WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('globalsearch') THEN 'Menu - Global Search'
  WHEN a.Identifier = 'notificationsbutton' THEN 'Notifications'
  WHEN a.Identifier = 'profilebutton' AND iu.UserId = CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Self View' 
  WHEN a.Identifier = 'profilebutton' AND iu.UserId <> CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Other Attendee View'
  WHEN a.Identifier = 'editprofilebutton' THEN 'Profile - Edit'
  WHEN a.Identifier = 'profilepicturebutton' AND iu.UserId = CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Picture (Self)'
  WHEN a.Identifier = 'profilepicturebutton' AND iu.UserId <> CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Picture (Other)'
  WHEN a.Identifier = 'profileaboutbutton' AND iu.UserId = CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - About (Self)' 
  WHEN a.Identifier = 'profileaboutbutton' AND iu.UserId <> CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - About (Other)'
  WHEN a.Identifier = 'profileactivitybutton' AND iu.UserId = CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Activity (Self)' 
  WHEN a.Identifier = 'profileactivitybutton' AND iu.UserId <> CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Activity (Other)'
  WHEN a.Identifier = 'profilenetworkbutton' AND iu.UserId = CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Network (Self)' 
  WHEN a.Identifier = 'profilenetworkbutton' AND iu.UserId <> CAST(a.Metadata ->> 'userid' AS INT) THEN 'Profile - Network (Other)'
  WHEN a.Identifier IN ('profilebutton') AND iu.UserId IS NULL THEN 'Profile (Unknown)'
  WHEN a.Identifier IN ('profilepicturebutton') AND iu.UserId IS NULL THEN 'Profile - Picture (Unknown)'
  WHEN a.Identifier IN ('profileaboutbutton') AND iu.UserId IS NULL THEN 'Profile - About (Unknown)'
  WHEN a.Identifier IN ('profileactivitybutton') AND iu.UserId IS NULL THEN 'Profile - Activity (Unknown)'
  WHEN a.Identifier IN ('profilenetworkbutton') AND iu.UserId IS NULL THEN 'Profile - Network (Unknown)'
  WHEN a.Identifier = 'socialnetworkbutton' AND CAST(a.Metadata ->> 'network' AS TEXT) = 'facebook' THEN 'Attendee Facebook'
  WHEN a.Identifier = 'socialnetworkbutton' AND CAST(a.Metadata ->> 'network' AS TEXT) = 'linkedin' THEN 'Attendee Linkedin'
  WHEN a.Identifier = 'socialnetworkbutton' AND CAST(a.Metadata ->> 'network' AS TEXT) = 'twitter' THEN 'Attendee Twitter'
  WHEN a.Identifier = 'newpostbutton' THEN 'Status Update - New'
  WHEN a.Identifier = 'cancelpostbutton' THEN 'Status Update - Cancel'
  WHEN a.Identifier = 'submitpostbutton' THEN 'Status Update - Submit'
  WHEN a.Identifier = 'likebutton' AND CAST(a.Metadata ->> 'toggledto' AS TEXT) = 'on' THEN 'Like - On'
  WHEN a.Identifier = 'likebutton' AND CAST(a.Metadata ->> 'toggledto' AS TEXT) = 'off' THEN 'Like - Off'
  WHEN a.Identifier = 'followbutton' AND CAST(a.Metadata ->> 'toggledto' AS TEXT) = 'on' THEN 'Follow - On'
  WHEN a.Identifier = 'followbutton' AND CAST(a.Metadata ->> 'toggledto' AS TEXT) = 'off' THEN 'Follow - Off'
  WHEN a.Identifier = 'bookmarkbutton' AND CAST(a.Metadata ->> 'toggledto' AS TEXT) = 'on' THEN 'Bookmark - On'
  WHEN a.Identifier = 'bookmarkbutton' AND CAST(a.Metadata ->> 'toggledto' AS TEXT) = 'off' THEN 'Bookmark - Off'
  WHEN a.Identifier = 'startcommentbutton' THEN 'Comment - New'
  WHEN a.Identifier = 'submitcommentbutton' THEN 'Comment - Submit'
  WHEN a.Identifier = 'startsendmessage' THEN 'Message - New'
  WHEN a.Identifier = 'submitsendmessage' THEN 'Message - Submit'
  WHEN a.Identifier = 'hashtagbutton' THEN 'Hashtag - Tap'
  WHEN a.Identifier = 'mentionbutton' THEN 'Mention - Tap'
  WHEN a.Identifier = 'promotedpost' THEN 'Promoted Post'
  WHEN a.Identifier = 'upcomingsessionbutton' THEN 'Activity Feed Card - Upcoming Session'
  WHEN a.Identifier = 'surveystocompletebutton' THEN 'Activity Feed Card - Surveys to Complete'
  WHEN a.Identifier = 'satisfactionbutton' THEN 'Activity Feed Card - Satisfaction'
  WHEN a.Identifier = 'startpollbutton' THEN 'Poll - Start'
  WHEN a.Identifier = 'submitpollbutton' THEN 'Poll - Submit'
  WHEN a.Identifier = 'viewpollresultsbutton' THEN 'Poll - View Results'
  WHEN a.Identifier = 'startsurveybutton' THEN 'Survey - Start'
  WHEN a.Identifier = 'surveyselectbutton' THEN 'Survey - Select'
  WHEN a.Identifier = 'submitsurveyresponsebutton' THEN 'Survey Question - Submit Answer'
  WHEN a.Identifier = 'checkinbutton' THEN 'Check In'
  WHEN a.Identifier = 'ratebutton' THEN 'Rate'
  WHEN a.Identifier = 'scanleadbutton' THEN 'Leads - Scan'
  WHEN a.Identifier = 'addleadnotebutton' THEN 'Leads - Start Note'
  WHEN a.Identifier = 'submitleadnotebutton' THEN 'Leads - Submit Note'
  WHEN a.Identifier = 'canceladdleadnotebutton' THEN 'Leads - Cancel Note'
  WHEN a.Identifier = 'itembutton' THEN 'Item'
  ELSE 'Other'
END AS Tapped,
a.Identifier, 
a.Metadata,
--MenuItem Tap
CASE WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('url','web') THEN CASE WHEN CAST(a.Metadata AS TEXT) LIKE '%url %' THEN CAST(a.Metadata ->> 'url ' AS TEXT) ELSE CAST(a.Metadata ->> 'url' AS TEXT) END END AS URL,
CASE WHEN a.Identifier IN ('menuitem') AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('item') THEN CAST(a.Metadata ->> 'itemid' AS TEXT) WHEN a.Identifier IN ('itembutton') THEN CAST(a.Metadata ->> 'itemid' AS TEXT) END AS ItemId,
CASE WHEN a.Identifier = 'menuitem' AND LOWER(CAST(a.Metadata ->> 'type' AS TEXT)) IN ('list','topic') THEN CAST(a.Metadata ->> 'listid' AS TEXT) END AS ListId
--========================
FROM (
        SELECT UPPER(Application_Id) AS ApplicationId, UPPER(Global_User_Id) AS GlobalUserId, Identifier, Metadata, Created    
        FROM PUBLIC.Fact_Actions_New a
        WHERE a.Identifier IN ('menuitem','itembutton','notificationsbutton','profilebutton','editprofilebutton', 'profilepicturebutton', 'profileactivitybutton', 'profileaboutbutton', 'profilenetworkbutton', 'profileaboutbutton', 'socialnetworkbutton', 'newpostbutton', 'cancelpostbutton', 'submitpostbutton', 'likebutton', 'followbutton', 'bookmarkbutton', 'startcommentbutton', 'submitcommentbutton', 'startsendmessage', 'submitsendmessage', 'hashtagbutton', 'mentionbutton', 'promotedpost', 'upcomingsessionbutton', 'surveystocompletebutton', 'satisfactionbutton', 'startpollbutton', 'submitpollbutton', 'viewpollresultsbutton', 'startsurveybutton', 'surveyselectbutton' , 'submitsurveyresponsebutton', 'checkinbutton', 'ratebutton', 'scanleadbutton', 'addleadnotebutton', 'submitleadnotebutton', 'canceladdleadnotebutton')
) a
JOIN AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
LEFT JOIN AuthDB_IS_Users iu ON a.GlobalUserId = iu.GlobalUserId
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






UNION ALL







--newMetrics
SELECT a.ApplicationId, a.Tapped, a.Identifier, a.Metadata, a.Url AS URL, a.ItemId, a.ListId
FROM (

SELECT ApplicationId, Tapped, Identifier, Metadata, CAST(NULL AS TEXT) AS Url, CAST(NULL AS INT) AS ItemId, CAST(NULL AS INT) AS ListId FROM Report.NewMetrics_Actions_Chat UNION ALL
SELECT ApplicationId, Tapped, Identifier, Metadata, CAST(NULL AS TEXT) AS Url, ItemId, CAST(NULL AS INT) AS ListId FROM Report.NewMetrics_Actions_Feed UNION ALL
SELECT ApplicationId, Tapped, Identifier, Metadata, CAST(NULL AS TEXT) AS Url, ItemId, ListId FROM Report.NewMetrics_Actions_Item UNION ALL
SELECT ApplicationId, Tapped, Identifier, Metadata, Url, ItemId, ListId FROM Report.NewMetrics_Actions_MenuItem UNION ALL
SELECT ApplicationId, Tapped, Identifier, Metadata, CAST(NULL AS TEXT) AS Url, CAST(NULL AS INT) AS ItemId, CAST(NULL AS INT) AS ListId FROM Report.NewMetrics_Actions_Other UNION ALL
SELECT ApplicationId, Tapped, Identifier, Metadata, CAST(NULL AS TEXT) AS Url, CAST(NULL AS INT) AS ItemId, CAST(NULL AS INT) AS ListId FROM Report.NewMetrics_Actions_Profile UNION ALL
SELECT ApplicationId, Tapped, Identifier, Metadata, CAST(NULL AS TEXT) AS Url, ItemId, CAST(NULL AS INT) AS ListId FROM Report.NewMetrics_Actions_Survey

) a
JOIN AuthDB_Applications app ON a.ApplicationId = app.ApplicationId
LEFT JOIN AuthDB_IS_Users iu ON a.GlobalUserId = iu.GlobalUserId
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
DROP TABLE IF EXISTS dashboard.kpi_event_tapspct;
CREATE TABLE dashboard.kpi_event_tapspct AS
SELECT DISTINCT base.ApplicationId, app.Name, Tapped, COUNT(*) OVER (PARTITION BY base.ApplicationId, Tapped) AS Taps, SUM(1) OVER (PARTITION BY base.ApplicationId) AS TotalTaps, 100 * CAST(COUNT(*) OVER (PARTITION BY base.ApplicationId, Tapped) AS NUMERIC) / CAST(SUM(1) OVER (PARTITION BY base.ApplicationId) AS NUMERIC) AS PCT_Taps
FROM (
        SELECT  m.ApplicationId, 
                CASE 
                  WHEN m.Tapped IN ('Item','Menu - Item') AND i.Name IS NOT NULL THEN CASE WHEN m.ItemId IS NOT NULL THEN 'Item ('||REPLACE(i.Name,',','')||')' ELSE 'Other' END 
                  WHEN m.Tapped IN ('Item','Menu - Item') AND if.Name IS NOT NULL THEN CASE WHEN m.ItemId IS NOT NULL THEN 'File ('||REPLACE(if.Name,',','')||')' ELSE 'Other' END 
                  WHEN m.Tapped IN ('Menu - Folder','Menu - List') THEN CASE WHEN m.ListId IS NOT NULL THEN 'Folder ('||REPLACE(t.Name,',','')||')' ELSE 'Other' END 
                  WHEN m.Tapped IN ('Menu - Web View') THEN CASE WHEN m.URL IS NOT NULL THEN 'URL ('||REPLACE(m.URL,',','')||')' ELSE 'Other' END 
                  ELSE m.Tapped 
                END AS Tapped 
        FROM Event_Taps m
        LEFT JOIN Ratings_Item i ON CAST(m.ItemId AS INT) = i.ItemId 
        LEFT JOIN Ratings_ItemFiles if ON CAST(m.ItemId AS INT) = if.FileId
        LEFT JOIN Ratings_Topic t ON CAST(m.ListId AS INT) = t.TopicId 
        WHERE m.Tapped IN ('Item','Menu - Item','Menu - Folder','Menu - List','Menu - Web View')
        UNION ALL
        SELECT ApplicationId, Tapped FROM Event_Taps WHERE Tapped NOT IN ('Item','Menu - Item','Menu - Folder','Menu - List','Menu - Web View')
) base
JOIN AuthDB_Applications app ON base.ApplicationId = app.ApplicationId
ORDER BY 1,5 DESC;

--Identify the ranking on items tapped selected per Event
DROP TABLE IF EXISTS dashboard.kpi_event_tap_top;
CREATE TABLE dashboard.kpi_event_tap_top AS 
SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY ApplicationId ORDER BY PCT_Taps DESC, Tapped DESC) AS RNK FROM dashboard.kpi_event_tapspct) t;
