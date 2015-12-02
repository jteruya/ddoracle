SELECT 
CASE 
  WHEN a.SF_IsClosed = 'true' AND a.SF_IsWon = 'true' THEN 'Closed Won' 
  WHEN a.SF_IsClosed = 'true' AND a.SF_IsWon = 'false' THEN 'Closed Lost' 
  WHEN a.SF_IsClosed = 'false' AND a.SF_IsWon = 'false' THEN 'Open' 
END AS "Sales Pipeline",
a.SF_AccountId AS "AccountID", 
REPLACE(a.SF_Name,',',' -') AS "Event Name", 
TO_CHAR(CAST(a.SF_CreatedDate AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') AS "Opportunity Created", 
TO_CHAR(CAST(a.SF_LastModifiedDate AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') AS "Opportunity Last Modified", 
a.SF_Days_From_Create_To_Close__c AS "SalesForce - Days from Create to Closed", 
b.SF_Email_domain__c AS "Related Email Domain"
FROM Integrations.Opportunity a
LEFT JOIN Integrations.Account b ON a.SF_AccountId = b.SF_Id
WHERE a.SF_CampaignId LIKE '701E0000000apGd%' OR a.SF_CampaignId LIKE '701E0000000alw9%'
ORDER BY a.SF_CreatedDate DESC;


