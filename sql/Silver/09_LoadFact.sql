USE EMSRecords;
GO

INSERT INTO er.Fact_EMS_Response (
    row_hash,
    incident_dt_id,
    unit_notified_by_dispatch_dt_id,
    unit_arrived_on_scene_dt_id,
    unit_arrived_to_patient_dt_id,
    unit_left_scene_dt_id,
    patient_arrived_destination_dt_id,
    incident_county_id,
    chief_complaint_dispatch_id,
    chief_complaint_anatomic_loc_id,
    primary_symptom_id,
    provider_impression_primary_id,
    disposition_ed_id,
    disposition_hospital_id,
    destination_type_id,
    provider_type_id,
    injury_flg,
    naloxone_given_flg,
    medication_given_other_flg,
    provider_to_scene_mins,
    provider_to_destination_mins,
    response_count
)
SELECT
    s.row_hash,

    COALESCE(dd_inc.date_id, 0),
    COALESCE(dd_disp.date_id, 0),
    COALESCE(dd_on.date_id, 0),
    COALESCE(dd_pat.date_id, 0),
    COALESCE(dd_left.date_id, 0),
    COALESCE(dd_dest.date_id, 0),

    COALESCE(dc.county_id, 0),
    COALESCE(dccd.chief_complaint_dispatch_id, 0),
    COALESCE(dcal.chief_complaint_anatomic_loc_id, 0),
    COALESCE(dps.primary_symptom_id, 0),
    COALESCE(dpip.provider_impression_primary_id, 0),
    COALESCE(ded.disposition_ed_id, 0),
    COALESCE(dh.disposition_hospital_id, 0),
    COALESCE(ddt.destination_type_id, 0),
    COALESCE(dpt.provider_type_id, 0),

    s.injury_flg,
    s.naloxone_given_flg,
    s.medication_given_other_flg,
    s.provider_to_scene_mins,
    s.provider_to_destination_mins,
    1
FROM er.Stg_EMS_Runs s
LEFT JOIN er.Dim_Date dd_inc  ON dd_inc.date_id  = COALESCE(CONVERT(INT, CONVERT(CHAR(8), CAST(s.incident_dt AS DATE), 112)), 0)
LEFT JOIN dberer.Dim_Date dd_disp ON dd_disp.date_id = COALESCE(CONVERT(INT, CONVERT(CHAR(8), CAST(s.unit_notified_by_dispatch_dt AS DATE), 112)), 0)
LEFT JOIN er.Dim_Date dd_on   ON dd_on.date_id   = COALESCE(CONVERT(INT, CONVERT(CHAR(8), CAST(s.unit_arrived_on_scene_dt AS DATE), 112)), 0)
LEFT JOIN er.Dim_Date dd_pat  ON dd_pat.date_id  = COALESCE(CONVERT(INT, CONVERT(CHAR(8), CAST(s.unit_arrived_to_patient_dt AS DATE), 112)), 0)
LEFT JOIN er.Dim_Date dd_left ON dd_left.date_id = COALESCE(CONVERT(INT, CONVERT(CHAR(8), CAST(s.unit_left_scene_dt AS DATE), 112)), 0)
LEFT JOIN er.Dim_Date dd_dest ON dd_dest.date_id = COALESCE(CONVERT(INT, CONVERT(CHAR(8), CAST(s.patient_arrived_destination_dt AS DATE), 112)), 0)

LEFT JOIN er.Dim_County dc ON dc.incident_county = COALESCE(s.incident_county, 'Unknown')
LEFT JOIN er.Dim_Chief_Complaint_Dispatch dccd ON dccd.chief_complaint_dispatch = COALESCE(s.chief_complaint_dispatch, 'Unknown')
LEFT JOIN er.Dim_Chief_Complaint_Anatomic_Loc dcal ON dcal.chief_complaint_anatomic_loc = COALESCE(s.chief_complaint_anatomic_loc, 'Unknown')
LEFT JOIN er.Dim_Primary_Symptom dps ON dps.primary_symptom = COALESCE(s.primary_symptom, 'Unknown')
LEFT JOIN er.Dim_Provider_Impression_Primary dpip ON dpip.provider_impression_primary = COALESCE(s.provider_impression_primary, 'Unknown')
LEFT JOIN er.Dim_Disposition_ED ded ON ded.disposition_ed = COALESCE(s.disposition_ed, 'Unknown')
LEFT JOIN er.Dim_Disposition_Hospital dh ON dh.disposition_hospital = COALESCE(s.disposition_hospital, 'Unknown')
LEFT JOIN er.Dim_Destination_Type ddt ON ddt.destination_type = COALESCE(s.destination_type, 'Unknown')

LEFT JOIN er.Dim_Provider_Type dpt
  ON ISNULL(dpt.provider_type_structure, '') = ISNULL(s.provider_type_structure, '')
 AND ISNULL(dpt.provider_type_service, '') = ISNULL(s.provider_type_service, '')
 AND ISNULL(dpt.provider_type_service_level, '') = ISNULL(s.provider_type_service_level, '')

WHERE NOT EXISTS (
    SELECT 1
    FROM er.Fact_EMS_Response f
    WHERE f.row_hash = s.row_hash
);
GO
