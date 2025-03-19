-- Find tenants with ny1br greater than avg
-- needs a cast becase data is loaded as varchars as staging from csv
Select [Tenant],[Space_number], try_cast( NewYear1BR as decimal(10,2)) as NewYear1BR_Num
From [dbo].[LPM] where try_cast(NewYear1BR as decimal(10,2))>= 
(
	SELECT Avg(try_cast(NewYear1_baseRent as decimal(10,2)))
  FROM [dbo].[LPM]
   )
