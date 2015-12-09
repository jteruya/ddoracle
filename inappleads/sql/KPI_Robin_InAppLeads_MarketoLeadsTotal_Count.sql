SELECT COUNT(*) 
FROM Marketo.Leads 
WHERE Email NOT LIKE '%doubledutch.me'
AND ProgramId IN (1670,1593)
AND Email <> 'NULL';