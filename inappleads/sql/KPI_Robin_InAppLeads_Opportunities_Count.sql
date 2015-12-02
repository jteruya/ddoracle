-- Count of Opportunities originating from App-By-DoubleDutch Web Form completion
SELECT COUNT(*) FROM (
SELECT 
a.SF_AccountId AS "AccountID", 
REPLACE(a.SF_Name,',',' -') AS "Event Name"
FROM Integrations.Opportunity a
WHERE a.SF_CampaignId LIKE '701E0000000apGd%' OR a.SF_CampaignId LIKE '701E0000000alw9%'
) t