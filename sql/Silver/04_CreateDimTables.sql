USE EMSRecords;
GO

DROP TABLE IF EXISTS er.Fact_EMS_Response;
GO

-- Dim_Date
DROP TABLE IF EXISTS er.Dim_Date;
GO
CREATE TABLE er.Dim_Date (
    date_id      INT NOT NULL,         -- YYYYMMDD or 0
    [date]       DATE NOT NULL,
    [year]       INT NOT NULL,
    [month]      INT NOT NULL,
    month_name   NVARCHAR(20) NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week  INT NOT NULL,
    day_name     NVARCHAR(20) NOT NULL,
    [quarter]    INT NOT NULL,
    CONSTRAINT PK_Dim_Date PRIMARY KEY (date_id)
);
GO

-- Dim_County
DROP TABLE IF EXISTS er.Dim_County;
GO
CREATE TABLE er.Dim_County (
    county_id       INT IDENTITY(1,1) NOT NULL,
    incident_county NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_County PRIMARY KEY (county_id),
    CONSTRAINT UQ_Dim_County UNIQUE (incident_county)
);
GO

-- Dim_Chief_Complaint_Dispatch
DROP TABLE IF EXISTS er.Dim_Chief_Complaint_Dispatch;
GO
CREATE TABLE er.Dim_Chief_Complaint_Dispatch (
    chief_complaint_dispatch_id INT IDENTITY(1,1) NOT NULL,
    chief_complaint_dispatch    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Chief_Complaint_Dispatch PRIMARY KEY (chief_complaint_dispatch_id),
    CONSTRAINT UQ_Dim_Chief_Complaint_Dispatch UNIQUE (chief_complaint_dispatch)
);
GO

-- Dim_Chief_Complaint_Anatomic_Loc
DROP TABLE IF EXISTS er.Dim_Chief_Complaint_Anatomic_Loc;
GO
CREATE TABLE er.Dim_Chief_Complaint_Anatomic_Loc (
    chief_complaint_anatomic_loc_id INT IDENTITY(1,1) NOT NULL,
    chief_complaint_anatomic_loc    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Chief_Complaint_Anatomic_Loc PRIMARY KEY (chief_complaint_anatomic_loc_id),
    CONSTRAINT UQ_Dim_Chief_Complaint_Anatomic_Loc UNIQUE (chief_complaint_anatomic_loc)
);
GO

-- Dim_Primary_Symptom
DROP TABLE IF EXISTS er.Dim_Primary_Symptom;
GO
CREATE TABLE er.Dim_Primary_Symptom (
    primary_symptom_id INT IDENTITY(1,1) NOT NULL,
    primary_symptom    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Primary_Symptom PRIMARY KEY (primary_symptom_id),
    CONSTRAINT UQ_Dim_Primary_Symptom UNIQUE (primary_symptom)
);
GO

-- Dim_Provider_Impression_Primary
DROP TABLE IF EXISTS er.Dim_Provider_Impression_Primary;
GO
CREATE TABLE er.Dim_Provider_Impression_Primary (
    provider_impression_primary_id INT IDENTITY(1,1) NOT NULL,
    provider_impression_primary    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Provider_Impression_Primary PRIMARY KEY (provider_impression_primary_id),
    CONSTRAINT UQ_Dim_Provider_Impression_Primary UNIQUE (provider_impression_primary)
);
GO

-- Dim_Destination_Type
DROP TABLE IF EXISTS er.Dim_Destination_Type;
GO
CREATE TABLE er.Dim_Destination_Type (
    destination_type_id INT IDENTITY(1,1) NOT NULL,
    destination_type    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Destination_Type PRIMARY KEY (destination_type_id),
    CONSTRAINT UQ_Dim_Destination_Type UNIQUE (destination_type)
);
GO

-- Dim_Provider_Type
DROP TABLE IF EXISTS er.Dim_Provider_Type;
GO
CREATE TABLE er.Dim_Provider_Type (
    provider_type_id        INT IDENTITY(1,1) NOT NULL,
    provider_type_structure NVARCHAR(254) NULL,
    provider_type_service   NVARCHAR(254) NULL,
    provider_type_service_level NVARCHAR(254) NULL,
    CONSTRAINT PK_Dim_Provider_Type PRIMARY KEY (provider_type_id),
    CONSTRAINT UQ_Dim_Provider_Type UNIQUE (provider_type_structure, provider_type_service, provider_type_service_level)
);
GO

-- Dim_Disposition_ED
DROP TABLE IF EXISTS er.Dim_Disposition_ED;
GO
CREATE TABLE er.Dim_Disposition_ED (
    disposition_ed_id INT IDENTITY(1,1) NOT NULL,
    disposition_ed    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Disposition_ED PRIMARY KEY (disposition_ed_id),
    CONSTRAINT UQ_Dim_Disposition_ED UNIQUE (disposition_ed)
);
GO

-- Dim_Disposition_Hospital
DROP TABLE IF EXISTS er.Dim_Disposition_Hospital;
GO
CREATE TABLE er.Dim_Disposition_Hospital (
    disposition_hospital_id INT IDENTITY(1,1) NOT NULL,
    disposition_hospital    NVARCHAR(254) NOT NULL,
    CONSTRAINT PK_Dim_Disposition_Hospital PRIMARY KEY (disposition_hospital_id),
    CONSTRAINT UQ_Dim_Disposition_Hospital UNIQUE (disposition_hospital)
);
GO
    