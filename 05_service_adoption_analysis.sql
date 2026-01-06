use telco;

#service adoption rates comparison
select 'phone service' as service, sum(case when PhoneService='Yes' then 1 else 0 end) as customers_with_service,
round(sum(case when PhoneService='Yes' then 1 else 0 end) * 100.0/count(*), 2) as adoptation_rate,
round(avg(case when PhoneService='Yes' then MonthlyCharges else null end),2) as avg_charge_with_service,
round(avg(case when PhoneService='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) as churn_rate_with_service from telco
union all
select 'online security', sum(case when OnlineSecurity='Yes' then 1 else 0 end),
round(sum(case when OnlineSecurity='Yes' then 1 else 0 end) * 100.0/count(*), 2),
round(avg(case when OnlineSecurity='Yes' then MonthlyCharges else null end),2),
round(avg(case when OnlineSecurity='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) from telco
union all
select 'online backup', sum(case when OnlineBackup='Yes' then 1 else 0 end),
round(sum(case when OnlineBackup='Yes' then 1 else 0 end) * 100.0/count(*), 2),
round(avg(case when OnlineBackup='Yes' then MonthlyCharges else null end),2),
round(avg(case when OnlineBackup='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) from telco
union all
select 'device protection', sum(case when DeviceProtection='Yes' then 1 else 0 end),
round(sum(case when DeviceProtection='Yes' then 1 else 0 end) * 100.0/count(*), 2),
round(avg(case when DeviceProtection='Yes' then MonthlyCharges else null end),2),
round(avg(case when DeviceProtection='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) from telco
union all
select 'tech support', sum(case when TechSupport='Yes' then 1 else 0 end),
round(sum(case when TechSupport='Yes' then 1 else 0 end) * 100.0/count(*), 2),
round(avg(case when TechSupport='Yes' then MonthlyCharges else null end),2),
round(avg(case when TechSupport='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) from telco
union all
select 'streaming tv', sum(case when StreamingTV='Yes' then 1 else 0 end),
round(sum(case when StreamingTV='Yes' then 1 else 0 end) * 100.0/count(*), 2),
round(avg(case when StreamingTV='Yes' then MonthlyCharges else null end),2),
round(avg(case when StreamingTV='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) from telco
union all
select 'streaming movies', sum(case when StreamingMovies='Yes' then 1 else 0 end),
round(sum(case when StreamingMovies='Yes' then 1 else 0 end) * 100.0/count(*), 2),
round(avg(case when StreamingMovies='Yes' then MonthlyCharges else null end),2),
round(avg(case when StreamingMovies='Yes' and churn='Yes' then 1.0 else 0.0 end) * 100, 2) from telco;

#customers without key services (upsell opportunities)
select customerID, tenure, Contract, round(MonthlyCharges, 2) as current_monthly_charge, round(TotalCharges, 2) as lifetime_value,
case when OnlineSecurity='No' then 'online security' else null end as upsell_1,
case when TechSupport='No' then 'tech support' else null end as upsell_2,
case when OnlineBackup='No' then 'online backup' else null end as upsell_3,
case when DeviceProtection='No' then 'device protection' else null end as upsell_4,
(case when tenure>24 then 30 else 15 end +
case when Contract!='Month-to-month' then 20 else 0 end +
case when MonthlyCharges<70 then 15 else 0 end) as upsell_potential_score from telco
where churn='No' and InternetService!='No' and (OnlineSecurity = 'No' or TechSupport = 'No' or OnlineBackup= 'No' or DeviceProtection = 'No')
order by upsell_potential_score desc, TotalCharges desc limit 100;

#service bundle impact on churn
select case when PhoneService='Yes' and InternetService!='No' then 'phone + internet bundle'
when PhoneService='Yes' and InternetService='No' then 'phone only'
when PhoneService='No' and InternetService!='No' then 'internet only'
else 'no core services' end as service_bundle, count(*) as customers,
round(avg(MonthlyCharges),2) as avg_monthly_charge, round(avg(tenure),1) as avg_tenure,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*) * 100,2) as churn_rate from telco group by service_bundle order by churn_rate;

#security services impact
select case when OnlineSecurity='Yes' and OnlineBackup='Yes' and DeviceProtection='Yes' and TechSupport='Yes'
then 'all 4 security services'
when (case when OnlineSecurity='Yes' then 1 else 0 end +
case when OnlineBackup='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end +
case when TechSupport='Yes' then 1 else 0 end)>=2 then '2-3 security services'
when (case when OnlineSecurity='Yes' then 1 else 0 end +
case when OnlineBackup='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end +
case when TechSupport='Yes' then 1 else 0 end)>=1 then '1 security service'
else 'no security services' end as security_package, count(*) as customers,
round(avg(MonthlyCharges),2) as avg_monthly_charge, round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*)*100,2) as churn_rate,
round(avg(tenure),1) as avg_tenure from telco where InternetService!='No' group by security_package order by churn_rate;

#multiple lines impact
select MultipleLines, count(*) as customers, round(avg(MonthlyCharges),2) as average_monthly_charge,
round(avg(tenure),1) as average_tenure, round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*) * 100,2) as churn_rate
from telco where PhoneService='Yes' group by MultipleLines order by churn_rate;

#service revenue contribution
select InternetService as service_type, 'internet' as service_category, count(*) as customers,
round(sum(MonthlyCharges),2) as total_monthly_revenue, round(avg(MonthlyCharges),2) as avg_revenue_per_customer,
round(sum(MonthlyCharges)*100.0/(select sum(MonthlyCharges) from telco),2) as revenue_contribution_percentage
from telco group by InternetService
union all
select Contract, 'contract type', count(*),
round(sum(MonthlyCharges),2), round(avg(MonthlyCharges),2),
round(sum(MonthlyCharges)*100.0/(select sum(MonthlyCharges) from telco),2) from telco group by Contract
order by total_monthly_revenue desc;