USE EMSRecords;
GO

-- Row counts
SELECT 'Raw_EMS_Runs' AS table_name, COUNT(*) AS row_count FROM dbo.Raw_EMS_Runs
UNION ALL
SELECT 'Stg_EMS_Runs', COUNT(*) FROM er.Stg_EMS_Runs
UNION ALL
SELECT 'Dim_Date', COUNT(*) FROM er.Dim_Date
UNION ALL
SELECT 'Dim_County', COUNT(*) FROM er.Dim_County
UNION ALL
SELECT 'Dim_Chief_Complaint_Dispatch', COUNT(*) FROM er.Dim_Chief_Complaint_Dispatch
UNION ALL
SELECT 'Dim_Chief_Complaint_Anatomic_Loc', COUNT(*) FROM er.Dim_Chief_Complaint_Anatomic_Loc
UNION ALL
SELECT 'Dim_Primary_Symptom', COUNT(*) FROM er.Dim_Primary_Symptom
UNION ALL
SELECT 'Dim_Provider_Impression_Primary', COUNT(*) FROM er.Dim_Provider_Impression_Primary
UNION ALL
SELECT 'Dim_Disposition_ED', COUNT(*) FROM er.Dim_Disposition_ED
UNION ALL
SELECT 'Dim_Disposition_Hospital', COUNT(*) FROM er.Dim_Disposition_Hospital
UNION ALL
SELECT 'Dim_Destination_Type', COUNT(*) FROM er.Dim_Destination_Type
UNION ALL
SELECT 'Dim_Provider_Type', COUNT(*) FROM er.Dim_Provider_Type
UNION ALL
SELECT 'Fact_EMS_Response', COUNT(*) FROM er.Fact_EMS_Response;
GO

-- Duplicate row_hash in staging (should be 0)
SELECT COUNT(*) AS dup_row_hash_count
FROM (
    SELECT row_hash
    FROM er.Stg_EMS_Runs
    GROUP BY row_hash
    HAVING COUNT(*) > 1
) d;
GO

-- Duplicate row_hash in fact (should be 0, unique constraint enforces)
SELECT COUNT(*) AS dup_row_hash_count_fact
FROM (
    SELECT row_hash
    FROM er.Fact_EMS_Response
    GROUP BY row_hash
    HAVING COUNT(*) > 1
) d;
GO
