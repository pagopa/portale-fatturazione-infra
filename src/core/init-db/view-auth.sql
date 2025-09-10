--
-- Utility queries for inspecting auth.
--

-- view roles
SELECT dp.name, sp.name
FROM sys.database_role_members drm
LEFT JOIN sys.database_principals dp ON drm.member_principal_id=dp.principal_id
LEFT JOIN sys.database_principals sp ON drm.role_principal_id=sp.principal_id
ORDER BY dp.name;

-- view permissions including sp
SELECT dp.class_desc as perm_context
     , dp2.name AS user_name
     , dp.permission_name
     , o.name AS object_name
     , o.type_desc
FROM sys.database_permissions AS dp
    INNER JOIN sys.database_principals AS dp2
        ON dp.grantee_principal_id = dp2.principal_id
    LEFT JOIN sys.objects AS o
        ON dp.major_id = o.object_id
WHERE dp.major_id >= 0;
