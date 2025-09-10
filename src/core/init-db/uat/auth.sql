-- uat --
-- WARNING: this file requires a manual apply against the Azure SQL DB
-- please refer to:
---- 00_azuread.tf for ad groups
---- 20_synapse.tf for the azurerm_synapse_workspace resource name

DROP PROCEDURE IF EXISTS CreateUser;
DROP PROCEDURE IF EXISTS AddRoleToUser;
GO

CREATE PROCEDURE CreateUser
    @user NVARCHAR(64)
AS
BEGIN
    DECLARE @sql_statement NVARCHAR(MAX);
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @user)
    BEGIN
        SET @sql_statement = 'CREATE USER ' + QUOTENAME(@user) + ' FROM EXTERNAL PROVIDER WITH DEFAULT_SCHEMA = [dbo]';
        EXEC sp_executesql @sql_statement;
    END;
END;
GO

CREATE PROCEDURE AddRoleToUser
    @user NVARCHAR(64),
    @role NVARCHAR(64)
AS
BEGIN
    DECLARE @sql_statement NVARCHAR(MAX);
    IF NOT EXISTS (SELECT * FROM sys.database_role_members WHERE member_principal_id = (
    SELECT principal_id FROM sys.database_principals WHERE name = @user
    ) AND role_principal_id = (
        SELECT principal_id FROM sys.database_principals WHERE name = @role
    ))
    BEGIN
	    SET @sql_statement = 'ALTER ROLE ' + QUOTENAME(@role) + ' ADD MEMBER ' + QUOTENAME(@user);
        EXEC sp_executesql @sql_statement;
    END;
END;
GO

DECLARE @user NVARCHAR(64);

-- fat-u-adgroup-admin --
SET @user = 'fat-u-adgroup-admin'
EXEC CreateUser @user
EXEC AddRoleToUser @user, 'db_owner'

-- fat-u-adgroup-developers --
SET @user = 'fat-u-adgroup-developers'
EXEC CreateUser @user
EXEC AddRoleToUser @user, 'db_datareader'
EXEC AddRoleToUser @user, 'db_datawriter'

-- fat-u-synw --
SET @user = 'fat-u-synw'
EXEC CreateUser @user
EXEC AddRoleToUser @user, 'db_datareader'
EXEC AddRoleToUser @user, 'db_datawriter'
-- FIXME unable to execute this one:
-- EXEC AddRoleToUser @user, 'ddladmin'

-- fat-u-app-api --
SET @user = 'fat-u-app-api'
EXEC CreateUser @user
EXEC AddRoleToUser @user, 'db_datareader'
EXEC AddRoleToUser @user, 'db_datawriter'
GRANT EXECUTE ON [pfd].[RipristinaFattura] TO @user
GO
GRANT EXECUTE ON [pfd].[SospendiFattura] TO @user
GO
GRANT EXECUTE ON TYPE::[pfd].[RipristinoFatture] TO @user
GO

-- fat-u-api-func --
SET @user = 'fat-u-api-func'
EXEC CreateUser @user
EXEC AddRoleToUser @user, 'db_datareader'
EXEC AddRoleToUser @user, 'db_datawriter'

-- fat-u-integration-func --
SET @user = 'fat-u-integration-func'
EXEC CreateUser @user
EXEC AddRoleToUser @user, 'db_datareader'
EXEC AddRoleToUser @user, 'db_datawriter'
