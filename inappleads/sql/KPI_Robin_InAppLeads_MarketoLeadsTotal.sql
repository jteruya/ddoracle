SELECT * 
FROM Marketo.Leads 
WHERE ProgramId IN (1670,1593)
AND Email <> 'NULL'
ORDER BY UpdatedAt DESC;