USE EMSRecords;
GO

-- Dim_Date unknown row
IF NOT EXISTS (SELECT 1 FROM er.Dim_Date WHERE date_id = 0)
BEGIN
    INSERT INTO er.Dim_Date(date_id, [date], [year], [month], month_name, day_of_month, day_of_week, day_name, [quarter])
    VALUES (0, '1900-01-01', 1900, 1, 'Unknown', 1, 1, 'Unknown', 1);
END
GO

-- County
IF NOT EXISTS (SELECT 1 FROM er.Dim_County WHERE county_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_County ON;
    INSERT INTO er.Dim_County(county_id, incident_county) VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_County OFF;
END
GO

-- Complaint Dispatch
IF NOT EXISTS (SELECT 1 FROM er.Dim_Chief_Complaint_Dispatch WHERE chief_complaint_dispatch_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Chief_Complaint_Dispatch ON;
    INSERT INTO er.Dim_Chief_Complaint_Dispatch(chief_complaint_dispatch_id, chief_complaint_dispatch)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Chief_Complaint_Dispatch OFF;
END
GO

-- Complaint Anatomic Loc
IF NOT EXISTS (SELECT 1 FROM er.Dim_Chief_Complaint_Anatomic_Loc WHERE chief_complaint_anatomic_loc_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Chief_Complaint_Anatomic_Loc ON;
    INSERT INTO er.Dim_Chief_Complaint_Anatomic_Loc(chief_complaint_anatomic_loc_id, chief_complaint_anatomic_loc)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Chief_Complaint_Anatomic_Loc OFF;
END
GO

-- Primary Symptom
IF NOT EXISTS (SELECT 1 FROM er.Dim_Primary_Symptom WHERE primary_symptom_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Primary_Symptom ON;
    INSERT INTO er.Dim_Primary_Symptom(primary_symptom_id, primary_symptom)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Primary_Symptom OFF;
END
GO

-- Provider Impression
IF NOT EXISTS (SELECT 1 FROM er.Dim_Provider_Impression_Primary WHERE provider_impression_primary_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Provider_Impression_Primary ON;
    INSERT INTO er.Dim_Provider_Impression_Primary(provider_impression_primary_id, provider_impression_primary)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Provider_Impression_Primary OFF;
END
GO

-- Destination Type
IF NOT EXISTS (SELECT 1 FROM er.Dim_Destination_Type WHERE destination_type_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Destination_Type ON;
    INSERT INTO er.Dim_Destination_Type(destination_type_id, destination_type)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Destination_Type OFF;
END
GO

-- Provider Type
IF NOT EXISTS (SELECT 1 FROM er.Dim_Provider_Type WHERE provider_type_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Provider_Type ON;
    INSERT INTO er.Dim_Provider_Type(provider_type_id, provider_type_structure, provider_type_service, provider_type_service_level)
    VALUES (0, 'Unknown', 'Unknown', 'Unknown');
    SET IDENTITY_INSERT er.Dim_Provider_Type OFF;
END
GO

-- Disposition ED
IF NOT EXISTS (SELECT 1 FROM er.Dim_Disposition_ED WHERE disposition_ed_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Disposition_ED ON;
    INSERT INTO er.Dim_Disposition_ED(disposition_ed_id, disposition_ed)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Disposition_ED OFF;
END
GO

-- Disposition Hospital
IF NOT EXISTS (SELECT 1 FROM er.Dim_Disposition_Hospital WHERE disposition_hospital_id = 0)
BEGIN
    SET IDENTITY_INSERT er.Dim_Disposition_Hospital ON;
    INSERT INTO er.Dim_Disposition_Hospital(disposition_hospital_id, disposition_hospital)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT er.Dim_Disposition_Hospital OFF;
END
GO
