-- prod --
-- WARNING: this file requires a manual apply against the Azure SQL DB
-- please refer to:
---- 00_azuread.tf for ad groups
---- 20_synapse.tf for the azurerm_synapse_workspace resource name

DECLARE @group NVARCHAR(64);
DECLARE @role NVARCHAR(64);
DECLARE @auxiliary_role NVARCHAR(64);

-- fat-p-adgroup-admin -- db_owner role --
SET @group = 'fat-p-adgroup-admin'
SET @role = 'db_owner'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @group)
BEGIN
    CREATE USER [@group] FROM EXTERNAL PROVIDER WITH DEFAULT_SCHEMA = [dbo]
END;
IF NOT EXISTS (SELECT * FROM sys.database_role_members WHERE member_principal_id = (
    SELECT principal_id FROM sys.database_principals WHERE name = @group
    ) AND role_principal_id = (
        SELECT principal_id FROM sys.database_principals WHERE name = @role
    ))
BEGIN
	ALTER ROLE [@role] ADD MEMBER [@group];
END;

-- fat-p-adgroup-developers -- db_ddladmin role --
SET @group = 'fat-p-adgroup-developers'
SET @role = 'db_ddladmin'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @group)
BEGIN
    CREATE USER [@group] FROM EXTERNAL PROVIDER WITH DEFAULT_SCHEMA = [dbo]
END;
IF NOT EXISTS (SELECT * FROM sys.database_role_members WHERE member_principal_id = (
    SELECT principal_id FROM sys.database_principals WHERE name = @group
    ) AND role_principal_id = (
        SELECT principal_id FROM sys.database_principals WHERE name = @role
    ))
BEGIN
	ALTER ROLE [@role] ADD MEMBER [@group];
END;

-- fat-p-synw -- db_datareader + db_datawriter role --
SET @group = 'fat-p-synw'
SET @role = 'db_datareader'
SET @auxiliary_role = 'db_datawriter'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @group)
BEGIN
    CREATE USER [@group] FROM EXTERNAL PROVIDER WITH DEFAULT_SCHEMA = [dbo]
END;
IF NOT EXISTS (SELECT * FROM sys.database_role_members WHERE member_principal_id = (
    SELECT principal_id FROM sys.database_principals WHERE name = @group
    ) AND role_principal_id = (
        SELECT principal_id FROM sys.database_principals WHERE name = @role
    ))
BEGIN
	ALTER ROLE [@role] ADD MEMBER [@group];
    ALTER ROLE [@auxiliary_role] ADD MEMBER [@group];
END;
