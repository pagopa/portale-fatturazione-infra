SELECT dp.name, sp.name FROM sys.database_role_members drm 
LEFT JOIN sys.database_principals dp ON drm.member_principal_id=dp.principal_id
LEFT JOIN sys.database_principals sp ON drm.role_principal_id=sp.principal_id