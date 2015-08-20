--Per each Event, flag if any of the specific features was used
DROP TABLE IF EXISTS dashboard.kpi_social_metrics_featureused_flags;
CREATE TABLE dashboard.kpi_social_metrics_featureused_flags AS
SELECT
app.ApplicationId,
CASE WHEN messages.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS MessagesUsed_Ind,
CASE WHEN poll.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS PollSetup_Ind,
CASE WHEN polls.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS PollsUsed_Ind,
CASE WHEN hashtags.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS HashtagsUsed_Ind,
CASE WHEN mentions.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS MentionsUsed_Ind,
CAST(EXTRACT(YEAR FROM app.StartDate) AS INT) || '-' || CASE WHEN CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) < 10 THEN '0' ELSE '' END || CAST(EXTRACT(MONTH FROM app.StartDate) AS INT) AS YYYY_MM
FROM AuthDB_Applications app
LEFT JOIN (SELECT DISTINCT ApplicationId FROM PUBLIC.Ratings_UserMessages) messages ON app.ApplicationId = messages.ApplicationId
LEFT JOIN (SELECT DISTINCT ApplicationId FROM PUBLIC.Ratings_Surveys WHERE IsPoll = 'true' AND IsDisabled = 'false') poll ON app.ApplicationId = poll.ApplicationId
LEFT JOIN (SELECT DISTINCT s.ApplicationId FROM PUBLIC.Ratings_SurveyResponses sr JOIN PUBLIC.Ratings_SurveyQuestions sq ON sr.SurveyQuestionId = sq.SurveyQuestionId JOIN PUBLIC.Ratings_Surveys s ON sq.SurveyId = s.SurveyId WHERE s.IsPoll = 'true' AND s.IsDisabled = 'false') polls ON app.ApplicationId = polls.ApplicationId
LEFT JOIN (SELECT DISTINCT uci.ApplicationId FROM PUBLIC.Ratings_HashtagInstances hi JOIN PUBLIC.Ratings_UserCheckIns uci ON hi.CheckInId = uci.CheckInId) hashtags ON app.ApplicationId = hashtags.ApplicationId
LEFT JOIN (SELECT DISTINCT iu.ApplicationId FROM PUBLIC.Ratings_MentionInstances mi JOIN PUBLIC.AuthDB_IS_Users iu ON mi.UserId = iu.UserId) mentions ON app.ApplicationId = mentions.ApplicationId
WHERE app.StartDate <= CURRENT_DATE --Only Events that have already started
AND app.StartDate >= CURRENT_DATE - INTERVAL'7 months'
AND app.ApplicationId NOT IN (SELECT ApplicationId FROM EventCube.TestEvents) --Remove Test Events
;
