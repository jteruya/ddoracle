SELECT 
a.SF_StageName AS "Sales Pipeline",
a.SF_AccountId AS "AccountID", 
REPLACE(a.SF_Name,',',' -') AS "Event Name", 
TO_CHAR(CAST(a.SF_X1_Identifiy_Timestamp__c AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') AS "Identify Date",
CASE WHEN a.SF_X2_Prospect_Timestamp__c IS NOT NULL AND a.SF_X2_Prospect_Timestamp__c <> '' THEN TO_CHAR(CAST(a.SF_X2_Prospect_Timestamp__c AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') ELSE NULL END AS "Prospect Date",
CASE WHEN a.SF_X3_Quote_Timestamp__c IS NOT NULL AND a.SF_X3_Quote_Timestamp__c <> '' THEN TO_CHAR(CAST(a.SF_X3_Quote_Timestamp__c AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') ELSE NULL END AS "Quote Date",
CASE WHEN a.SF_X4_Negotiate_Timestamp__c IS NOT NULL AND a.SF_X4_Negotiate_Timestamp__c <> '' THEN TO_CHAR(CAST(a.SF_X4_Negotiate_Timestamp__c AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') ELSE NULL END AS "Negotiate Date",
CASE WHEN a.SF_CloseDate IS NOT NULL AND a.SF_CloseDate <> '' THEN TO_CHAR(CAST(a.SF_CloseDate AS TIMESTAMP),'YYYY-MM-DD HH24:MI:SS') ELSE NULL END AS "Close Date",
a.SF_Days_From_Create_To_Close__c AS "Days from Create to Closed", 
b.SF_Email_domain__c AS "Related Email Domain"
FROM Integrations.Opportunity a
LEFT JOIN Integrations.Account b ON a.SF_AccountId = b.SF_Id
WHERE a.SF_CampaignId LIKE '701E0000000apGd%' OR a.SF_CampaignId LIKE '701E0000000alw9%'
ORDER BY a.SF_CreatedDate DESC
LIMIT 10;