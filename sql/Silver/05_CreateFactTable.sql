USE EMSRecords;
GO

DROP TABLE IF EXISTS er.Fact_EMS_Response;
GO

CREATE TABLE er.Fact_EMS_Response (
    ems_response_id BIGINT IDENTITY(1,1) NOT NULL,
    row_hash        VARBINARY(32) NOT NULL,

    incident_dt_id                  INT NOT NULL DEFAULT 0,
    unit_notified_by_dispatch_dt_id INT NOT NULL DEFAULT 0,
    unit_arrived_on_scene_dt_id     INT NOT NULL DEFAULT 0,
    unit_arrived_to_patient_dt_id   INT NOT NULL DEFAULT 0,
    unit_left_scene_dt_id           INT NOT NULL DEFAULT 0,
    patient_arrived_destination_dt_id INT NOT NULL DEFAULT 0,

    incident_county_id              INT NOT NULL DEFAULT 0,
    chief_complaint_dispatch_id     INT NOT NULL DEFAULT 0,
    chief_complaint_anatomic_loc_id INT NOT NULL DEFAULT 0,
    primary_symptom_id              INT NOT NULL DEFAULT 0,
    provider_impression_primary_id  INT NOT NULL DEFAULT 0,
    disposition_ed_id               INT NOT NULL DEFAULT 0,
    disposition_hospital_id         INT NOT NULL DEFAULT 0,
    destination_type_id             INT NOT NULL DEFAULT 0,
    provider_type_id                INT NOT NULL DEFAULT 0,

    injury_flg                   BIT NULL,
    naloxone_given_flg           BIT NULL,
    medication_given_other_flg   BIT NULL,
    provider_to_scene_mins       DECIMAL(10,2) NULL,
    provider_to_destination_mins DECIMAL(10,2) NULL,
    response_count               INT NOT NULL DEFAULT 1,

    etl_loaded_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Fact_EMS_Response PRIMARY KEY (ems_response_id),
    CONSTRAINT UQ_Fact_EMS_Response_row_hash UNIQUE (row_hash)
);
GO

-- FKs to Dim_Date (role-playing)
ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_Date_Incident
FOREIGN KEY (incident_dt_id) REFERENCES er.Dim_Date(date_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_Date_Dispatch
FOREIGN KEY (unit_notified_by_dispatch_dt_id) REFERENCES er.Dim_Date(date_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_Date_OnScene
FOREIGN KEY (unit_arrived_on_scene_dt_id) REFERENCES er.Dim_Date(date_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_Date_PatientContact
FOREIGN KEY (unit_arrived_to_patient_dt_id) REFERENCES er.Dim_Date(date_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_Date_LeftScene
FOREIGN KEY (unit_left_scene_dt_id) REFERENCES er.Dim_Date(date_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_Date_Destination
FOREIGN KEY (patient_arrived_destination_dt_id) REFERENCES er.Dim_Date(date_id);
GO

-- FKs to other dims
ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_County
FOREIGN KEY (incident_county_id) REFERENCES er.Dim_County(county_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_ComplaintDispatch
FOREIGN KEY (chief_complaint_dispatch_id) REFERENCES er.Dim_Chief_Complaint_Dispatch(chief_complaint_dispatch_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_ComplaintAnatomicLoc
FOREIGN KEY (chief_complaint_anatomic_loc_id) REFERENCES er.Dim_Chief_Complaint_Anatomic_Loc(chief_complaint_anatomic_loc_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_PrimarySymptom
FOREIGN KEY (primary_symptom_id) REFERENCES er.Dim_Primary_Symptom(primary_symptom_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_ProviderImpression
FOREIGN KEY (provider_impression_primary_id) REFERENCES er.Dim_Provider_Impression_Primary(provider_impression_primary_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_DispositionED
FOREIGN KEY (disposition_ed_id) REFERENCES er.Dim_Disposition_ED(disposition_ed_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_DispositionHospital
FOREIGN KEY (disposition_hospital_id) REFERENCES er.Dim_Disposition_Hospital(disposition_hospital_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_DestinationType
FOREIGN KEY (destination_type_id) REFERENCES er.Dim_Destination_Type(destination_type_id);

ALTER TABLE er.Fact_EMS_Response WITH CHECK ADD CONSTRAINT FK_Fact_ProviderType
FOREIGN KEY (provider_type_id) REFERENCES er.Dim_Provider_Type(provider_type_id);
GO
