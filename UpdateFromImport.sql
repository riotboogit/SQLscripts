Select BusUnit_ID, Unit_ID, a.Lease_ID, b.lease_ID, TenantProspect, b.tenant, SQFT, Term_Years, EstimatedRentStart_date from 
  MASTER_WH.[dbo].[fact_on_actuals] a 
  left join [dbo].[LeaseIDUpdate] b on a.TenantProspect = b.Tenant and a.SQFT = b.gla 
  where a.Lease_ID = -1
  and Year(EstimatedRentStart_date) = 2025
  

Begin Tran

Select * from [dbo].[fact_on_actuals] where TenantProspect in (Select Tenant from [dbo].[LeaseIDUpdate] ) and Lease_ID = -1

Update a
Set a.Lease_ID = b.Lease_ID
from [dbo].[fact_on_actuals] a 
inner join [dbo].[LeaseIDUpdate] b 
on b.Tenant = a.TenantProspect 
and b.GLA = a.SQFT 
and Year(b.Estimated_RCD) = Year(a.EstimatedREntStart_date)
where a.Lease_ID = -1

Select distinct TenantProspect from [dbo].[fact_on_actuals] where TenantProspect in (Select Tenant from [dbo].[LeaseIDUpdate] ) and Lease_ID = -1

Rollback

