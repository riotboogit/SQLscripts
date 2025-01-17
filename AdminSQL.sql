-- find jobs/owners
SELECT J.name AS Job_Name
, P.name AS Job_Owner
FROM msdb.dbo.sysjobs J
INNER JOIN
sys.server_principals P
ON J.owner_sid = P.sid
GO
