-- Creates EMSRecords database if it doesn't exist
IF DB_ID('EMSRecords') IS NULL
BEGIN
    CREATE DATABASE EMSRecords;
END
GO
