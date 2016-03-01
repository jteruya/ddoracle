SELECT 
  b.Name AS "Job", 
  a.BatchId AS "Batch", 
  a.Filename AS "Metric Log", 
  a.Data_Size AS "Metric Log (Size)", 
  a.Row_Count AS "Metric Log (Row Count)", 
  a.Row_Index AS "Metric Log (Current Process Index)", 
  a.Status AS "Status", 
  a.Last_Read_At AS "Last Read At"
FROM (
SELECT a.Id AS BatchId, a.Filename, a.Task_Id, a.Data_Size, a.Row_Count, a.Row_Index, a.Command, a.Status, a.Last_Read_At,
RANK() OVER (PARTITION BY a.Task_Id ORDER BY Id DESC) AS RNK
FROM JSON_Batch a
WHERE a.Task_Id IN (10,11,12,13,14,15,17,18,19,21,22,23,24,27)) a 
JOIN JSON_Task b ON a.Task_Id = b.Id
WHERE a.RNK <= 3
ORDER BY a.Task_Id DESC, a.Filename ASC;