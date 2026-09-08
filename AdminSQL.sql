-- find jobs/owners
SELECT J.name AS Job_Name
, P.name AS Job_Owner
FROM msdb.dbo.sysjobs J
INNER JOIN
sys.server_principals P
ON J.owner_sid = P.sid
GO


--create readonly server role and assign ad user
USE [master]
GO

CREATE LOGIN [CORPORATE\ADUserName] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO

CREATE SERVER ROLE [ReadOnlyAccess] AUTHORIZATION [securityadmin];


-- Allow the role to connect to any database
GRANT CONNECT ANY DATABASE TO [ReadOnlyAccess];

-- Grant the ability to view any database definition
GRANT VIEW ANY DEFINITION TO [ReadOnlyAccess];

-- Optionally, grant VIEW ANY DATABASE to see all databases
GRANT VIEW ANY DATABASE TO [ReadOnlyAccess];

-- Replace 'YourUser' with the actual login name
ALTER SERVER ROLE [ReadOnlyAccess] ADD MEMBER [CORPORATE\ADUserName];
