-- Find missing src records in ODS
SELECT distinct
       [P_srccd], P_desc ,S_srccd	  
  FROM [OPS_DB].[dbo].[st_LP_actuals]  ods where Not exists
  (
    Select 1  from [CRM_DB].[dbo].[MSTR_st_LP_actuals] mstr where 
    ods.P_srccd = mstr.P_srccd
  )
