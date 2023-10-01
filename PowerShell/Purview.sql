# SQL (Added in portal)

CREATE USER "sbx-pur-act" FROM EXTERNAL PROVIDER
GO

EXEC sp_addrolemember 'db_datareader', [sbx-pur-act]
GO
