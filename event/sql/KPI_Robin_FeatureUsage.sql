SELECT Typ, YYYY_MM, ROUND(PCT_EventsUsingFeature,2) AS PCT_EventsUsingFeature
FROM (

SELECT CAST('Direct Messages' AS TEXT) AS Typ, YYYY_MM, 
--COUNT(*) AS Events, SUM(MessagesUsed_Ind) AS EventsUsingFeature,
100 * CAST(SUM(MessagesUsed_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_EventsUsingFeature
FROM dashboard.kpi_social_metrics_featureused_flags
GROUP BY 1,2

UNION ALL

SELECT CAST('Hashtags' AS TEXT) AS Typ, YYYY_MM, 
--COUNT(*) AS Events, SUM(HashtagsUsed_Ind) AS EventsUsingFeature,
100 * CAST(SUM(HashtagsUsed_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_EventsUsingFeature
FROM dashboard.kpi_social_metrics_featureused_flags
GROUP BY 1,2

UNION ALL

SELECT CAST('Mentions' AS TEXT) AS Typ, YYYY_MM, 
--COUNT(*) AS Events, SUM(MentionsUsed_Ind) AS EventsUsingFeature,
100 * CAST(SUM(MentionsUsed_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_EventsUsingFeature
FROM dashboard.kpi_social_metrics_featureused_flags
GROUP BY 1,2

UNION ALL

SELECT CAST('Polls (when setup)' AS TEXT) AS Typ, YYYY_MM, 
--COUNT(*) AS Events, SUM(PollsUsed_Ind) AS EventsUsingFeature,
100 * CAST(SUM(PollsUsed_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC) AS PCT_EventsUsingFeature
FROM dashboard.kpi_social_metrics_featureused_flags
WHERE PollSetup_Ind = 1
GROUP BY 1,2

) t ORDER BY 1,2



