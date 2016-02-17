--====================================================================================================
--Set of all Events
CREATE OR REPLACE VIEW dashboard.Chat_Dim_Events AS
SELECT ApplicationId, Name, EventType, StartDate, EndDate FROM AuthDB_Applications
WHERE UPPER(ApplicationId) IN (SELECT DISTINCT ApplicationId FROM Report.NewMetrics_Actions_MenuItem WHERE Tapped = 'Menu - Messages');
--====================================================================================================

--All Users tied to these Events (with DD flagging)
DROP TABLE IF EXISTS dashboard.Chat_Dim_Users;
CREATE TABLE dashboard.Chat_Dim_Users AS
SELECT iu.ApplicationId, iu.UserId, CASE WHEN dd.GlobalUserId IS NULL THEN 0 ELSE 1 END AS DD_Ind
FROM AuthDB_IS_Users iu 
LEFT JOIN kevin.Ratings_GlobalUserDetails_DD_Only dd ON iu.GlobalUserId = dd.GlobalUserId AND iu.ApplicationId = dd.ApplicationId
WHERE iu.ApplicationId IN (SELECT ApplicationId FROM dashboard.Chat_Dim_Events)
AND iu.IsDisabled = 0;

--====================================================================================================

--Set of all Rooms and Members: channels.Members
DROP TABLE IF EXISTS dashboard.Chat_Dim_Rooms;
CREATE TABLE dashboard.Chat_Dim_Rooms AS
SELECT 
  ApplicationId,
  ChannelId, 
  Type,
  CASE WHEN DD_Members >= 1 THEN 1 ELSE 0 END AS DD_Ind 
FROM (
        SELECT 
          ApplicationId,
          ChannelId, 
          Type,
          SUM(DD_Ind) AS DD_Members 
        FROM (
                SELECT 
                  du.ApplicationId,
                  rm.ChannelId, 
                  rm.UserId, 
                  COALESCE(du.DD_Ind,0) AS DD_Ind,
                  rm2.Type
                FROM channels.Members rm
                JOIN channels.Rooms rm2 ON rm.ChannelId = rm2.Id
                JOIN dashboard.Chat_Dim_Users du ON rm.UserId = du.UserId
        ) t 
        GROUP BY 1,2,3
) t;

--====================================================================================================

--Messages Sent (w/ Channel, Sender, Recipient)
DROP TABLE IF EXISTS dashboard.Chat_Fact_MessagesSent;
CREATE TABLE dashboard.Chat_Fact_MessagesSent AS
SELECT 
e.ApplicationId, 
e.Created,
e.ChannelId,
iu.UserId AS S_UserId,
rm.UserId AS R_UserId,
CASE WHEN e.ChannelId IS NULL THEN 1 ELSE 0 END AS MessageSent_Bug
FROM Report.NewMetrics_Actions_Chat e
JOIN AuthDB_IS_Users iu ON e.ApplicationId = iu.ApplicationId AND e.GlobalUserId = iu.GlobalUserId
LEFT JOIN channels.Members rm ON e.ChannelId = rm.ChannelId AND iu.UserId <> rm.UserId
WHERE Tapped IN ('Chat (submit)')
AND iu.IsDisabled = 0
AND e.ApplicationId IN (SELECT ApplicationId FROM dashboard.Chat_Dim_Events);

--MenuItem tap on Messages
DROP TABLE IF EXISTS dashboard.Chat_Fact_MenuTapMessages;
CREATE TABLE dashboard.Chat_Fact_MenuTapMessages AS
SELECT 
e.ApplicationId,
e.Created,
iu.UserId AS UserId
FROM Report.NewMetrics_Actions_MenuItem e
JOIN AuthDB_IS_Users iu ON e.ApplicationId = iu.ApplicationId AND e.GlobalUserId = iu.GlobalUserId
WHERE Tapped IN ('Menu - Messages')
AND e.ApplicationId IN (SELECT ApplicationId FROM dashboard.Chat_Dim_Events);

--Chat Views
DROP TABLE IF EXISTS dashboard.Chat_Fact_Views;
CREATE TABLE dashboard.Chat_Fact_Views AS
SELECT 
UPPER(e.Application_ID) AS ApplicationId,
e.Created,
iu.UserId,
CASE WHEN LENGTH(CAST(e.Metadata ->> 'ChannelId' AS TEXT)) > 9 THEN NULL ELSE CAST(e.Metadata ->> 'ChannelId' AS INT) END AS ChannelId,
CASE WHEN LENGTH(CAST(e.Metadata ->> 'ChannelId' AS TEXT)) > 9 THEN 1 ELSE 0 END AS ChannelId_Bug
FROM PUBLIC.Fact_Views_Live e
JOIN PUBLIC.AuthDB_IS_Users iu ON UPPER(e.Application_ID) = iu.ApplicationId AND UPPER(e.Global_User_Id) = iu.GlobalUserId
WHERE e.Identifier = 'chat';

--Block Actions
DROP TABLE IF EXISTS dashboard.Chat_Fact_Blocks;
CREATE TABLE dashboard.Chat_Fact_Blocks AS
SELECT
e.ApplicationId,
e.Created,
iu.UserId AS UserId
FROM report.NewMetrics_Actions_Chat e
JOIN AuthDB_IS_Users iu ON e.ApplicationId = iu.ApplicationId AND e.GlobalUserId = iu.GlobalUserId
WHERE e.Tapped = 'Chat (mute)'
AND e.ApplicationId IN (SELECT ApplicationId FROM dashboard.Chat_Dim_Events);

--====================================================================================================

--Conversations Recorded (Direct Messages ONLY)
DROP TABLE IF EXISTS dashboard.Chat_Agg_Conversations;
CREATE TABLE dashboard.Chat_Agg_Conversations AS
SELECT 
  rm.ApplicationId,
  rm.ChannelId,
  rm.DD_Ind,
  COALESCE(agg.Messages,0) AS Messages,
  COALESCE(agg.Messagers,0) AS Messagers,
  CASE 
    WHEN COALESCE(agg.Messagers,0) = 2 THEN 'Conversation' 
    WHEN COALESCE(agg.Messagers,0) = 1 THEN 'One-Side Conversation' 
    WHEN COALESCE(agg.Messagers,0) = 0 THEN 'Room Created - No Conversation' 
  END AS RoomType
FROM (SELECT DISTINCT ApplicationId, ChannelId, DD_Ind FROM dashboard.Chat_Dim_Rooms WHERE Type = 'GROUP') rm --Base set of Rooms
--Identify how many messages were sent and how many users sent messages in each room
LEFT JOIN (SELECT ChannelId, COUNT(*) AS Messages, COUNT(DISTINCT S_UserId) AS Messagers FROM dashboard.Chat_Fact_MessagesSent WHERE MessageSent_Bug = 0 GROUP BY 1) agg ON rm.ChannelId = agg.ChannelId
ORDER BY 1,2,3;

--====================================================================================================

--Aggregate: latest view per room per user
DROP TABLE IF EXISTS dashboard.Chat_Agg_RoomView;
CREATE TABLE dashboard.Chat_Agg_RoomView AS
SELECT ChannelId, UserId, MAX(Created) AS LatestViewTS FROM (
SELECT ChannelId, UserId, Created FROM dashboard.Chat_Fact_Views WHERE ChannelId_Bug = 0
UNION ALL 
SELECT ChannelId, S_UserId AS UserId, Created FROM dashboard.Chat_Fact_MessagesSent WHERE MessageSent_Bug = 0) t GROUP BY 1,2;

--Aggregate: latest sendMessage per room per user
DROP TABLE IF EXISTS dashboard.Chat_Agg_SendMessage;
CREATE TABLE dashboard.Chat_Agg_SendMessage AS
SELECT ChannelId, UserId, MAX(Created) AS LatestSendMessageTS FROM (
SELECT ChannelId, S_UserId AS UserId, Created FROM dashboard.Chat_Fact_MessagesSent WHERE MessageSent_Bug = 0) t GROUP BY 1,2;

--====================================================================================================

--Overall Users + Flagging
DROP TABLE IF EXISTS dashboard.Chat_Fact_UsersFlagged;
CREATE TABLE dashboard.Chat_Fact_UsersFlagged AS
SELECT 
  base.ApplicationId,
  base.UserId, 
  CASE WHEN sess.UserId IS NOT NULL THEN 1 ELSE 0 END AS Active_Ind, --Identify if User is Active
  CASE WHEN menuTapMessages.UserId IS NOT NULL THEN 1 ELSE 0 END AS menuTapMessages_Ind, --Identify if User tapped Menu Item for Messages
  CASE WHEN block.UserId IS NOT NULL THEN 1 ELSE 0 END AS block_Ind, --Identify if User was blocked in Messages
  CASE WHEN sentMessages.UserId IS NOT NULL THEN 1 ELSE 0 END AS sentMessage_Ind, --Identify if User sent a Message
  CASE WHEN recdMessages.UserId IS NOT NULL THEN 1 ELSE 0 END AS recdMessage_Ind, --Identify if User recevied a Message
  CASE WHEN recdMessages.UserId IS NOT NULL AND sess.UserId IS NOT NULL THEN 1 ELSE 0 END AS recdMessage_Active_Ind, --Identify if Active User recevied a Message
  CASE WHEN recdMessages.UserId IS NOT NULL AND sess.UserId IS NULL THEN 1 ELSE 0 END AS recdMessage_InActive_Ind --Identify if Active User recevied a Message
FROM dashboard.Chat_Dim_Users base
LEFT JOIN EventCube.Agg_Session_Per_AppUser sess ON base.UserId = sess.UserId
LEFT JOIN (SELECT DISTINCT UserId FROM dashboard.Chat_Fact_MenuTapMessages) menuTapMessages ON base.UserId = menuTapMessages.UserId
LEFT JOIN (SELECT DISTINCT UserId FROM dashboard.Chat_Fact_Blocks) block ON base.UserId = block.UserId
LEFT JOIN (SELECT DISTINCT S_UserId AS UserId FROM dashboard.Chat_Fact_MessagesSent) sentMessages ON base.UserId = sentMessages.UserId
LEFT JOIN (SELECT DISTINCT R_UserId AS UserId FROM dashboard.Chat_Fact_MessagesSent) recdMessages ON base.UserId = recdMessages.UserId
WHERE DD_Ind = 0; --Filter out DD

--====================================================================================================

--Overall Messages + Flagging for Views (Direct Messages)
DROP TABLE IF EXISTS dashboard.Chat_Fact_MessagesFlagged;
CREATE TABLE dashboard.Chat_Fact_MessagesFlagged AS
SELECT
  ms.ApplicationId,
  ms.ChannelId, 
  ms.S_UserId, 
  ms.R_UserId, 
  ms.Created AS MessageSentTS, 
  v.UserId, 
  v.LatestViewTS, 
  CASE WHEN v.LatestViewTS IS NOT NULL AND v.LatestViewTS >= ms.Created THEN 1 ELSE 0 END AS MessageViewed_Ind,
  CASE WHEN sm.LatestSendMessageTS IS NOT NULL AND sm.LatestSendMessageTS >= ms.Created THEN 1 ELSE 0 END AS MessageReplied_Ind
FROM dashboard.Chat_Fact_MessagesSent ms
LEFT JOIN dashboard.Chat_Agg_RoomView v ON ms.ChannelId = v.ChannelId AND ms.S_UserId <> v.UserId 
LEFT JOIN dashboard.Chat_Agg_SendMessage sm ON ms.ChannelId = sm.ChannelId AND ms.S_UserId <> sm.UserId
WHERE ms.MessageSent_Bug = 0
AND ms.ChannelId IN (SELECT ChannelId FROM dashboard.Chat_Dim_Rooms WHERE DD_INd = 0 AND Type = 'GROUP') --Filter out rooms with any DD users
ORDER BY ms.ApplicationId, ms.ChannelId, ms.Created;

--====================================================================================================

--Event-Level Aggregate for Messages (Direct Messages)
DROP TABLE IF EXISTS dashboard.Chat_Agg_Event;
CREATE TABLE dashboard.Chat_Agg_Event AS
SELECT 
  base.ApplicationId AS "ApplicationId", 
  app.Name AS "Event",
  rm.CNT AS "Total Rooms",
  ROUND(100 * CAST(COUNT(DISTINCT ChannelId) AS NUMERIC) / CAST(rm.CNT AS NUMERIC),2) AS "% Rooms with any Messages",
  ROUND(100 * CAST(rm_2conv.CNT AS NUMERIC) / CAST(rm.CNT AS NUMERIC),2) AS "% Rooms with 2-way Conversation",
  ROUND(100 * CAST(rm_1conv.CNT AS NUMERIC) / CAST(rm.CNT AS NUMERIC),2) AS "% Rooms with 1-way Conversation",
  ROUND(100 * CAST(rm_0conv.CNT AS NUMERIC) / CAST(rm.CNT AS NUMERIC),2) AS "% Rooms with no Conversation",
  
  ROUND(100 * CAST(SUM(MessageViewed_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS "% Messages followed by View from Recipient",
  ROUND(100 * CAST(SUM(MessageReplied_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS "% Messages followed by Reply Sent",
  
  COUNT(DISTINCT ChannelId) AS "Rooms - with any Messages", 
  rm_2conv.CNT AS "Rooms - with 2-way Conversation", 
  rm_1conv.CNT AS "Rooms - with 1-way Conversation", 
  rm_0conv.CNT AS "Rooms - with no Conversation", 
  COUNT(*) AS "Messages - Sent",
  SUM(MessageViewed_Ind) AS "Messages - followed by View from Recipient", 
  SUM(MessageReplied_Ind) AS "Messages - followed by Reply Sent"
FROM dashboard.Chat_Fact_MessagesFlagged base
JOIN dashboard.Chat_Dim_Events app ON base.ApplicationId = app.ApplicationId
LEFT JOIN (SELECT ApplicationId, COUNT(*) AS CNT FROM dashboard.Chat_Agg_Conversations WHERE DD_Ind = 0 GROUP BY 1) rm ON base.ApplicationId = rm.ApplicationId
LEFT JOIN (SELECT ApplicationId, RoomType, COUNT(*) AS CNT FROM dashboard.Chat_Agg_Conversations WHERE DD_Ind = 0 AND RoomType = 'Conversation' GROUP BY 1,2) rm_2conv ON base.ApplicationId = rm_2conv.ApplicationId
LEFT JOIN (SELECT ApplicationId, RoomType, COUNT(*) AS CNT FROM dashboard.Chat_Agg_Conversations WHERE DD_Ind = 0 AND RoomType = 'One-Side Conversation' GROUP BY 1,2) rm_1conv ON base.ApplicationId = rm_1conv.ApplicationId
LEFT JOIN (SELECT ApplicationId, RoomType, COUNT(*) AS CNT FROM dashboard.Chat_Agg_Conversations WHERE DD_Ind = 0 AND RoomType = 'Room Created - No Conversation' GROUP BY 1,2) rm_0conv ON base.ApplicationId = rm_0conv.ApplicationId
GROUP BY base.ApplicationId, app.Name, rm.CNT, rm_2conv.CNT, rm_1conv.CNT, rm_0conv.CNT;

--====================================================================================================

--User-Level Aggregate for Messages (Direct Messages)
DROP TABLE IF EXISTS dashboard.Chat_Agg_User;
CREATE TABLE dashboard.Chat_Agg_User AS
SELECT 
  base.ApplicationId AS "ApplicationId", 
  app.Name AS "Event",
  COUNT(*) AS  "Attendees Listed", 
  ROUND(100 * CAST(SUM(Active_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) AS "Adoption %",
  CASE WHEN SUM(Active_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(menuTapMessages_Ind) AS NUMERIC) / CAST(SUM(Active_Ind) AS NUMERIC),2) END AS "% of Active Attendees - Tapped Direct Messages in Menu",
  CASE WHEN SUM(Active_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(sentMessage_Ind) AS NUMERIC) / CAST(SUM(Active_Ind) AS NUMERIC),2) END AS "% of Active Attendees - Sent Message",
  CASE WHEN SUM(Active_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(recdMessage_Active_Ind) AS NUMERIC) / CAST(SUM(Active_Ind) AS NUMERIC),2) END AS "% of Active Attendees - Received Message",
  CASE WHEN COUNT(*) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(recdMessage_InActive_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS "% of Attendees - Inactive + Received Message (from CMS total)",
  CASE WHEN SUM(Active_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(block_Ind) AS NUMERIC) / CAST(SUM(Active_Ind) AS NUMERIC),2) END AS "% of Active Attendees - Were Blocked",
  SUM(Active_Ind) AS "Active Attendees",
  SUM(menuTapMessages_Ind) AS "Active Attendees - Tapped Direct Messages in Menu",
  SUM(sentMessage_Ind) AS "Active Attendees - Sent Message",
  SUM(recdMessage_Active_Ind) AS "Active Attendees - Received Message",
  SUM(recdMessage_InActive_Ind) AS "Inactive Attendees - Received Message",
  SUM(block_Ind) AS "Active Attendees - Were Blocked"
FROM dashboard.Chat_Fact_UsersFlagged base 
JOIN dashboard.Chat_Dim_Events app ON base.ApplicationId = app.ApplicationId
GROUP BY 1,2;

