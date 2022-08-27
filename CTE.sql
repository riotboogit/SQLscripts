

-- example for some basic sql functions

-- CTE example and how to choose ranked rows using SQL

-- suzanne

CREATE TABLE dbo.PAIDCHECKS (
CHECKID int IDENTITY(1,1) NOT NULL,
BANK VARCHAR(10) Default 'BOA',
CHECKNUM varchar(10) NOT NULL,
PAIDTO VARCHAR(100) NOT NULL,
PAIDDATE dateTime NOT NULL,
CHECKAMOUNT DECIMAL (10,2) NOT NULL
)

GO

-- using the random, floor  and date add functions

Insert into dbo.PAIDCHECKS VALUES

('312116', 'BOA' 'TED', Dateadd(DAY, -25, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 ),
('40208', 'FC' 'NAPOLEON', GETDATE(), FLOOR(RAND()*(250000-1000+1))+1000 ),
('1406', 'WF', 'RUFUS', GETDATE(), FLOOR(RAND()*(250000-1000+1))+1000 ),
(FLOOR(RAND()*(2500-1000+1))+1000 , 'FC' 'LINCOLN', Dateadd(DAY, -53, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 ),
('40236', BOA' 'SOCRATES', GETDATE(), FLOOR(RAND()*(250000-1000+1))+1000 ),
(FLOOR(RAND()*(2500-1000+1))+1000 , 'WF, 'RUFUS', Dateadd(DAY, -1351, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 ),
('32916', 'BOA' 'JOAN', Dateadd(DAY, -255, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 ),
('40228', 'FC', 'LINCOLN', GETDATE(), FLOOR(RAND()*(250000-1000+1))+1000 ),
('4061', 'WF', 'RUFUS', GETDATE(), FLOOR(RAND()*(250000-1000+1))+1000 ),
(FLOOR(RAND()*(2500-1000+1))+1000 ,'BOA', 'LINCOLN', Dateadd(DAY, -53, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 ),
('402361','FC', 'SOCRATES', GETDATE(), FLOOR(RAND()*(250000-1000+1))+1000 ),
(FLOOR(RAND()*(2500-1000+1))+1000 , 'BOA', 'RUFUS', Dateadd(DAY, -135, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 ),
(FLOOR(RAND()*(2500-1000+1))+1000 , 'BOA, 'NAPOLEON', Dateadd(DAY, -1, GETDATE()), FLOOR(RAND()*(250000-1000+1))+1000 )

GO;

 

-- find the Nth value SQL using a CTE
With TopChecks (checkID, PAIDTO, BANK, CHECKAMOUNT,amt_rank) as (

SELECT

      Top 5 checkID
      ,PAIDTO
      ,BANK
      ,CHECKAMOUNT
      ,row_number() over(
      partition by BANK order by CHECKAMOUNT desc
      )
        as amt_rank
    FROM [dbo].[PAIDCHECKS] where BANK = 'BOA'
  )

 

  Select * from TopChecks where amt_rank = 5;

 

