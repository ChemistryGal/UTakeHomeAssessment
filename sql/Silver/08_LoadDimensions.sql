USE EMSRecords;
GO

/* ------------------------------
   Load Dim_Date from staging dates
   ------------------------------ */
;WITH Dates AS (
    SELECT DISTINCT CAST(d.dt AS DATE) AS [date]
    FROM er.Stg_EMS_Runs s
    CROSS APPLY (VALUES
        (s.incident_dt),
        (s.unit_notified_by_dispatch_dt),
        (s.unit_arrived_on_scene_dt),
        (s.unit_arrived_to_patient_dt),
        (s.unit_left_scene_dt),
        (s.patient_arrived_destination_dt)
    ) d(dt)
    WHERE d.dt IS NOT NULL
)
INSERT INTO er.Dim_Date (date_id, [date], [year], [month], month_name, day_of_month, day_of_week, day_name, [quarter])
SELECT
    CONVERT(INT, CONVERT(CHAR(8), [date], 112)) AS date_id,
    [date],
    DATEPART(YEAR, [date]) AS [year],
    DATEPART(MONTH, [date]) AS [month],
    DATENAME(MONTH, [date]) AS month_name,
    DATEPART(DAY, [date]) AS day_of_month,
    DATEPART(WEEKDAY, [date]) AS day_of_week,
    DATENAME(WEEKDAY, [date]) AS day_name,
    DATEPART(QUARTER, [date]) AS [quarter]
FROM Dates d
WHERE NOT EXISTS (
    SELECT 1
    FROM er.Dim_Date dd
    WHERE dd.date_id = CONVERT(INT, CONVERT(CHAR(8), d.[date], 112))
);
GO

/* ------------------------------
   Other dimensions
   ------------------------------ */

-- County
INSERT INTO er.Dim_County (incident_county)
SELECT DISTINCT s.incident_county
FROM er.Stg_EMS_Runs s
WHERE s.incident_county IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_County d WHERE d.incident_county = s.incident_county);
GO

-- Chief Complaint Dispatch
INSERT INTO er.Dim_Chief_Complaint_Dispatch (chief_complaint_dispatch)
SELECT DISTINCT s.chief_complaint_dispatch
FROM er.Stg_EMS_Runs s
WHERE s.chief_complaint_dispatch IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Chief_Complaint_Dispatch d WHERE d.chief_complaint_dispatch = s.chief_complaint_dispatch);
GO

-- Chief Complaint Anatomic Loc
INSERT INTO er.Dim_Chief_Complaint_Anatomic_Loc (chief_complaint_anatomic_loc)
SELECT DISTINCT s.chief_complaint_anatomic_loc
FROM er.Stg_EMS_Runs s
WHERE s.chief_complaint_anatomic_loc IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Chief_Complaint_Anatomic_Loc d WHERE d.chief_complaint_anatomic_loc = s.chief_complaint_anatomic_loc);
GO

-- Primary Symptom
INSERT INTO er.Dim_Primary_Symptom (primary_symptom)
SELECT DISTINCT s.primary_symptom
FROM er.Stg_EMS_Runs s
WHERE s.primary_symptom IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Primary_Symptom d WHERE d.primary_symptom = s.primary_symptom);
GO

-- Provider Impression Primary
INSERT INTO er.Dim_Provider_Impression_Primary (provider_impression_primary)
SELECT DISTINCT s.provider_impression_primary
FROM er.Stg_EMS_Runs s
WHERE s.provider_impression_primary IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Provider_Impression_Primary d WHERE d.provider_impression_primary = s.provider_impression_primary);
GO

-- Disposition ED
INSERT INTO er.Dim_Disposition_ED (disposition_ed)
SELECT DISTINCT s.disposition_ed
FROM er.Stg_EMS_Runs s
WHERE s.disposition_ed IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Disposition_ED d WHERE d.disposition_ed = s.disposition_ed);
GO

-- Disposition Hospital
INSERT INTO er.Dim_Disposition_Hospital (disposition_hospital)
SELECT DISTINCT s.disposition_hospital
FROM er.Stg_EMS_Runs s
WHERE s.disposition_hospital IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Disposition_Hospital d WHERE d.disposition_hospital = s.disposition_hospital);
GO

-- Destination Type
INSERT INTO er.Dim_Destination_Type (destination_type)
SELECT DISTINCT s.destination_type
FROM er.Stg_EMS_Runs s
WHERE s.destination_type IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM er.Dim_Destination_Type d WHERE d.destination_type = s.destination_type);
GO

-- Provider Type (3-part)
INSERT INTO er.Dim_Provider_Type (provider_type_structure, provider_type_service, provider_type_service_level)
SELECT DISTINCT
    s.provider_type_structure,
    s.provider_type_service,
    s.provider_type_service_level
FROM er.Stg_EMS_Runs s
WHERE s.provider_type_structure IS NOT NULL
   OR s.provider_type_service IS NOT NULL
   OR s.provider_type_service_level IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM er.Dim_Provider_Type d
        WHERE ISNULL(d.provider_type_structure, '') = ISNULL(s.provider_type_structure, '')
          AND ISNULL(d.provider_type_service, '') = ISNULL(s.provider_type_service, '')
          AND ISNULL(d.provider_type_service_level, '') = ISNULL(s.provider_type_service_level, '')
  );
GO
