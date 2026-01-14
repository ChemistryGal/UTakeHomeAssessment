USE EMSRecords;
GO

TRUNCATE TABLE er.Stg_EMS_Runs;
GO

;WITH src AS (
    SELECT
        r.*,
        HASHBYTES(
            'SHA2_256',
            CONCAT_WS('|',
                NULLIF(LTRIM(RTRIM(r.INCIDENT_DT)), ''),
                NULLIF(LTRIM(RTRIM(r.INCIDENT_COUNTY)), ''),
                NULLIF(LTRIM(RTRIM(r.CHIEF_COMPLAINT_DISPATCH)), ''),
                NULLIF(LTRIM(RTRIM(r.CHIEF_COMPLAINT_ANATOMIC_LOC)), ''),
                NULLIF(LTRIM(RTRIM(r.PRIMARY_SYMPTOM)), ''),
                NULLIF(LTRIM(RTRIM(r.PROVIDER_IMPRESSION_PRIMARY)), ''),
                NULLIF(LTRIM(RTRIM(r.DISPOSITION_ED)), ''),
                NULLIF(LTRIM(RTRIM(r.DISPOSITION_HOSPITAL)), ''),
                NULLIF(LTRIM(RTRIM(r.DESTINATION_TYPE)), ''),
                NULLIF(LTRIM(RTRIM(r.PROVIDER_TYPE_STRUCTURE)), ''),
                NULLIF(LTRIM(RTRIM(r.PROVIDER_TYPE_SERVICE)), ''),
                NULLIF(LTRIM(RTRIM(r.PROVIDER_TYPE_SERVICE_LEVEL)), ''),
                NULLIF(LTRIM(RTRIM(r.PROVIDER_TO_SCENE_MINS)), ''),
                NULLIF(LTRIM(RTRIM(r.PROVIDER_TO_DESTINATION_MINS)), ''),
                NULLIF(LTRIM(RTRIM(r.UNIT_NOTIFIED_BY_DISPATCH_DT)), ''),
                NULLIF(LTRIM(RTRIM(r.UNIT_ARRIVED_ON_SCENE_DT)), ''),
                NULLIF(LTRIM(RTRIM(r.UNIT_ARRIVED_TO_PATIENT_DT)), ''),
                NULLIF(LTRIM(RTRIM(r.UNIT_LEFT_SCENE_DT)), ''),
                NULLIF(LTRIM(RTRIM(r.PATIENT_ARRIVED_DESTINATION_DT)), '')
            )
        ) AS row_hash_calc
    FROM er.Raw_EMS_Runs r
),
dedup AS (
    SELECT *
    FROM (
        SELECT
            src.*,
            ROW_NUMBER() OVER (PARTITION BY src.row_hash_calc ORDER BY (SELECT 1)) AS rn
        FROM src
    ) x
    WHERE x.rn = 1
)
INSERT INTO er.Stg_EMS_Runs (
    row_hash,
    incident_dt,
    unit_notified_by_dispatch_dt,
    unit_arrived_on_scene_dt,
    unit_arrived_to_patient_dt,
    unit_left_scene_dt,
    patient_arrived_destination_dt,
    incident_county,
    chief_complaint_dispatch,
    chief_complaint_anatomic_loc,
    primary_symptom,
    provider_impression_primary,
    disposition_ed,
    disposition_hospital,
    destination_type,
    provider_type_structure,
    provider_type_service,
    provider_type_service_level,
    injury_flg,
    naloxone_given_flg,
    medication_given_other_flg,
    provider_to_scene_mins,
    provider_to_destination_mins
)
SELECT
    d.row_hash_calc AS row_hash,

    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(d.INCIDENT_DT)), '')),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(d.UNIT_NOTIFIED_BY_DISPATCH_DT)), '')),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(d.UNIT_ARRIVED_ON_SCENE_DT)), '')),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(d.UNIT_ARRIVED_TO_PATIENT_DT)), '')),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(d.UNIT_LEFT_SCENE_DT)), '')),
    TRY_CONVERT(DATETIME2(0), NULLIF(LTRIM(RTRIM(d.PATIENT_ARRIVED_DESTINATION_DT)), '')),

    NULLIF(LTRIM(RTRIM(d.INCIDENT_COUNTY)), ''),
    NULLIF(LTRIM(RTRIM(d.CHIEF_COMPLAINT_DISPATCH)), ''),
    NULLIF(LTRIM(RTRIM(d.CHIEF_COMPLAINT_ANATOMIC_LOC)), ''),
    NULLIF(LTRIM(RTRIM(d.PRIMARY_SYMPTOM)), ''),
    NULLIF(LTRIM(RTRIM(d.PROVIDER_IMPRESSION_PRIMARY)), ''),
    NULLIF(LTRIM(RTRIM(d.DISPOSITION_ED)), ''),
    NULLIF(LTRIM(RTRIM(d.DISPOSITION_HOSPITAL)), ''),
    NULLIF(LTRIM(RTRIM(d.DESTINATION_TYPE)), ''),

    NULLIF(LTRIM(RTRIM(d.PROVIDER_TYPE_STRUCTURE)), ''),
    NULLIF(LTRIM(RTRIM(d.PROVIDER_TYPE_SERVICE)), ''),
    NULLIF(LTRIM(RTRIM(d.PROVIDER_TYPE_SERVICE_LEVEL)), ''),

    CASE
        WHEN NULLIF(LTRIM(RTRIM(d.INJURY_FLG)), '') IS NULL THEN NULL
        WHEN UPPER(LTRIM(RTRIM(d.INJURY_FLG))) IN ('1','Y','YES','TRUE','T') THEN 1
        WHEN UPPER(LTRIM(RTRIM(d.INJURY_FLG))) IN ('0','N','NO','FALSE','F') THEN 0
        ELSE NULL
    END,

    CASE
        WHEN NULLIF(LTRIM(RTRIM(d.NALOXONE_GIVEN_FLG)), '') IS NULL THEN NULL
        WHEN UPPER(LTRIM(RTRIM(d.NALOXONE_GIVEN_FLG))) IN ('1','Y','YES','TRUE','T') THEN 1
        WHEN UPPER(LTRIM(RTRIM(d.NALOXONE_GIVEN_FLG))) IN ('0','N','NO','FALSE','F') THEN 0
        ELSE NULL
    END,

    CASE
        WHEN NULLIF(LTRIM(RTRIM(d.MEDICATION_GIVEN_OTHER_FLG)), '') IS NULL THEN NULL
        WHEN UPPER(LTRIM(RTRIM(d.MEDICATION_GIVEN_OTHER_FLG))) IN ('1','Y','YES','TRUE','T') THEN 1
        WHEN UPPER(LTRIM(RTRIM(d.MEDICATION_GIVEN_OTHER_FLG))) IN ('0','N','NO','FALSE','F') THEN 0
        ELSE NULL
    END,

    CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(d.PROVIDER_TO_SCENE_MINS)), '')) < 0 THEN NULL
        ELSE TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(d.PROVIDER_TO_SCENE_MINS)), ''))
    END,

    CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(d.PROVIDER_TO_DESTINATION_MINS)), '')) < 0 THEN NULL
        ELSE TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(d.PROVIDER_TO_DESTINATION_MINS)), ''))
    END
FROM dedup d;
GO
