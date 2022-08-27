/*Author:    Suzanne Burgess 
created:     10.29.19
last updated 10.29.19
scripts to create RFM scoring for Adventure works data 
1.	Identify (list) the tables containing the relevant data.
[Person].[Person].[BusinessEntityID] CustomerID
[Person].[Person].[FirstName] + [Person].[Person].[LastName] Name
[Person].[Address].[AddressLine1] Address
[Person].[Address].[City] City
[Person].[Address].[State] State
[Person].[Address].[PostalCode] Zip
[Person].[CountryRegion].[CountryRegionName]   Country
[Person].[StateProvince].[Name] Province


*/


/*Author:    Suzanne Burgess 
created:     10.29.19
last updated 10.29.19
2.	Produce a list of customers living in France. The list should include: 
CustomerID, FirstName, LastName, Address, City, Zip, Province Name, and country.
3.	Produce a list of customers with number of orders placed and dollars spent. 
The list can include only the CustomerID, Number of Orders, and Total Money Spent columns. 
Use appropriate aggregate functions.
See views 
*/


CREATE view [Sales].[v_RFM_France]
 as 

SELECT  s.CustomerID as customer_id
		,p.FirstName +' '+p.LastName as Name
		,ic.AddressLine1 as [Address]
		,ic.City
		,ic.PostalCode as [PostCode]
		,ic.CountryRegionName 
        ,count(so.SalesOrderID) as salesCount
	    ,convert(Decimal(10,2),sum(so.TotalDue)) as revenue
		,convert(date,max(so.OrderDate)) as lastOrderDate
		,datediff(dd, '07/01/2014',max(so.OrderDate)) as LastOrderDays -- used 07/01/2014 as compare date
		
 FROM Sales.Customer s
 JOIN Person.Person p 
   ON s.CustomerID=p.BusinessEntityID
 LEFT JOIN Sales.SalesOrderHeader so
   ON s.CustomerID = so.CustomerID  
 
 inner join Sales.vIndividualCustomer ic 
   on ic.BusinessEntityID = s.CustomerID and ic.CountryRegionName = 'France'
 
 GROUP BY s.CustomerID, p.FirstName +' '+p.LastName 
        ,ic.City, ic.CountryRegionName
        ,ic.AddressLine1 
		,ic.City
		,ic.PostalCode
GO

/****** Script for SelectTopNRows command from SSMS  
This view computes the quintiles
base logic (Max value - Min Value) binned by * .20 to produces quintiles (equi-width binning)
creates a 1 record view with country to join to [Sales].[v_RFM_France]
******/
Create view [Sales].[v_RFM_quintiles]
as 
SELECT 

       'France' as 'Country' -- 
	    -- revenue
        ,min(revenue) as minM
	   ,(max(revenue) -min(revenue)) * .2 as FiQM
	   ,(max(revenue) -min(revenue)) * .4 as SQM
	   ,(max(revenue) -min(revenue)) * .6 as TQM
	   ,(max(revenue) -min(revenue)) * .8 as FoQM
	   ,max(revenue) as maxM
	   --sales_count
	   --Ceiling used to insure integer values
	    ,min(salescount) as minF
	   ,Ceiling((max(salescount) -min(salescount)) * .2) as FiQF
	   ,Ceiling((max(salescount) -min(salescount)) * .4) as SQF
	   ,Ceiling((max(salescount) -min(salescount)) * .6) as TQF
	   ,Ceiling((max(salescount) -min(salescount)) * .8) as FoQF
	   ,max(salescount) as maxF
	   --dayslastorder swap min for max since smaller numbers are more recent and produce higher score
	    ,max(LastOrderDays) as minR
	   ,(min(LastOrderDays) -max(LastOrderDays)) * .2 as FiQR
	   ,(min(LastOrderDays) -max(LastOrderDays)) * .4 as SQR
	   ,(min(LastOrderDays) -max(LastOrderDays)) * .6 as TQR
	   ,(min(LastOrderDays) -max(LastOrderDays)) * .8 as FoQR
	   ,min(LastOrderDays) as maxR

  FROM Sales.[v_RFM_France]
GO
/* 


*/

/*join above views to get Base RFM scores
4.	Produce a list of customers that can be utilized for your RFM analysis. The list needs to include 
CustomerID, first and last name, city, country, number of orders, total dollars spent, 
and last order date. The list needs to be limited to the search criteria specified above.
5.	Export the list to Excel (as shown below). Then, assign scores for each of the RFM dimensions. 
Sort the output according to the total RFM score (highest first).
*/




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Sales].[v_RFM_Scores]
as 
SELECT [CountryRegionName]
      ,[customer_id]
      ,[salescount]
      ,[revenue]
      ,[lastOrderDate]
	  ,LastOrderDays
	  
	  ,case when LastOrderDays >= (Select maxR from Sales.v_RFM_quintiles) and LastOrderDays < (Select FoQR from Sales.v_RFM_quintiles) then '1'
      when LastOrderDays >= (Select FoQR from Sales.v_RFM_quintiles) and LastOrderDays < (Select TQR from Sales.v_RFM_quintiles) then '2'
	  when LastOrderDays >= (Select TQR from Sales.v_RFM_quintiles) and LastOrderDays < (Select SQR from Sales.v_RFM_quintiles) then '3'
	  when LastOrderDays >= (Select SQR from Sales.v_RFM_quintiles) and LastOrderDays <(Select FiQR from Sales.v_RFM_quintiles) then '4'
	  else '5' End as RScore	 

	  ,case when salescount >= (Select minF from Sales.v_RFM_quintiles) and salescount < (Select FiQF from Sales.v_RFM_quintiles) then '1'
      when salescount >= (Select FiQF from Sales.v_RFM_quintiles) and salescount < (Select SQF from Sales.v_RFM_quintiles) then '2'
	  when salescount >= (Select SQF from Sales.v_RFM_quintiles) and salescount < (Select TQF from Sales.v_RFM_quintiles) then '3'
	  when salescount >= (Select TQF from Sales.v_RFM_quintiles) and salescount < (Select FoQF from Sales.v_RFM_quintiles) then '4'
	  else '5' end as FScore 

	  ,case when revenue >= (Select minM from Sales.v_RFM_quintiles) and revenue < (Select FiQM from Sales.v_RFM_quintiles) then '1'
      when revenue >= (Select FiQM from Sales.v_RFM_quintiles) and revenue < (Select SQM from Sales.v_RFM_quintiles) then '2'
	  when revenue >= (Select SQM from Sales.v_RFM_quintiles) and revenue < (Select TQM from Sales.v_RFM_quintiles) then '3'
	  when revenue >= (Select TQM from Sales.v_RFM_quintiles) and revenue < (Select FoQM from Sales.v_RFM_quintiles) then '4'
	  else '5' end as MScore
	  

  FROM [Sales].[v_RFM_France] s inner join [Sales].[v_RFM_quintiles] q on s.CountryRegionName = q.Country
GO



  
  /* final select for concatenated score 
  with Customer information */
  
  SELECT  
       s.[customer_id]
	  ,f.Name
	  ,f.Address
	  ,f.City
	  ,s.[CountryRegionName]
      ,s.[salescount]
      ,s.[revenue]
      ,s.[lastOrderDate]
      ,s.[LastOrderDays]
      ,s.[RScore]
      ,s.[FScore]
      ,s.[MScore]
	  ,s.[RScore] + [FScore] + [MScore] as RFMScore
  FROM [Sales].[v_RFM_Scores] s inner join [Sales].[v_RFM_France] f on s.Customer_id = f.customer_id


	
 
