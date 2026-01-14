-- Create Schema for Emergency Records
USE EMSRecords;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'er')
BEGIN
    EXEC('CREATE SCHEMA er;');
END
GO
