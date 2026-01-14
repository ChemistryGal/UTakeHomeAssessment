USE EMSRecords;
GO

DROP TABLE IF EXISTS er.Stg_EMS_Runs;
GO

CREATE TABLE er.Stg_EMS_Runs (
    row_hash                        VARBINARY(32) NOT NULL,

    incident_dt                      DATETIME2(0) NULL,
    unit_notified_by_dispatch_dt     DATETIME2(0) NULL,
    unit_arrived_on_scene_dt         DATETIME2(0) NULL,
    unit_arrived_to_patient_dt       DATETIME2(0) NULL,
    unit_left_scene_dt               DATETIME2(0) NULL,
    patient_arrived_destination_dt   DATETIME2(0) NULL,

    incident_county                  NVARCHAR(254) NULL,
    chief_complaint_dispatch         NVARCHAR(254) NULL,
    chief_complaint_anatomic_loc     NVARCHAR(254) NULL,
    primary_symptom                  NVARCHAR(254) NULL,
    provider_impression_primary      NVARCHAR(254) NULL,
    disposition_ed                   NVARCHAR(254) NULL,
    disposition_hospital             NVARCHAR(254) NULL,
    destination_type                 NVARCHAR(254) NULL,

    provider_type_structure          NVARCHAR(254) NULL,
    provider_type_service            NVARCHAR(254) NULL,
    provider_type_service_level      NVARCHAR(254) NULL,

    injury_flg                       BIT NULL,
    naloxone_given_flg               BIT NULL,
    medication_given_other_flg       BIT NULL,

    provider_to_scene_mins           DECIMAL(10,2) NULL,
    provider_to_destination_mins     DECIMAL(10,2) NULL
);
GO

CREATE UNIQUE INDEX IX_Stg_EMS_Runs_row_hash ON er.Stg_EMS_Runs(row_hash);
GO
