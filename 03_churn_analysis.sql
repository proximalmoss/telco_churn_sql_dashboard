use telco;

#overall churn rate
select count(*) as total_customers, sum(case when churn='Yes' then 1 else 0 end) as churned_customers,
sum(case when churn='No' then 1 else 0 end) as active_customers,
round(sum(case when churn = 'Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate_percentage,
round(sum(case when churn = 'No' then 1 else 0 end) * 100.0 / count(*), 2) as retention_rate_percentage
from telco;

#churn rate by contract type
select Contract, count(*) as total_customers,
sum(case when churn='Yes' then 1 else 0 end) as churned,
sum(case when churn='No' then 1 else 0 end) as retained,
round(sum(case when churn = 'Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate,
round(avg(tenure), 1) as avg_tenure,
round(avg(MonthlyCharges), 2) as avg_monthly_charge from telco group by Contract order by churn_rate desc;

#churn rate by tenure brackets
select case when tenure<=6 then '0-6 months'
when tenure<=12 then '7-12 months'
when tenure<=24 then '13-24 months'
when tenure<=36 then '25-36 months'
else '36+ months' end as tenure_bracket,
count(*) as total_customers,
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate,
round(avg(MonthlyCharges), 2) as avg_monthly_charge from telco group by tenure_bracket order by
case tenure_bracket
when '0-6 months' then 1
when '7-12 months' then 2
when '13-24 months' then 3
when '25-36 months' then 4 else 5 end;

#churn rate by internet service type
select InternetService, count(*) as customers,
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate,
round(avg(MonthlyCharges), 2) as avg_monthly_charge,
round(avg(tenure), 1) as avg_tenure from telco group by InternetService order by churn_rate desc;

#churn rate by payment method
select PaymentMethod, count(*) as customers, 
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate,
round(avg(MonthlyCharges), 2) as avg_monthly_charge,
round(avg(tenure), 1) as avg_tenure from telco group by PaymentMethod order by churn_rate desc;

#churn rate by tech support availability
select TechSupport, count(*) as customers, 
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate,
round(avg(tenure), 1) as avg_tenure from telco where InternetService!='No' group by TechSupport order by churn_rate desc;

#churn by online security
select OnlineSecurity, count(*) as customers,
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate
from telco where InternetService!='No' group by OnlineSecurity order by churn_rate desc;

#churn by senior citizen status
select case when SeniorCitizen=1 then 'senior' else 'non-senior' end as customer_type,
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate
from telco group by customer_type;

#churn by partner and dependents status
select Partner, Dependents, count(*) as customers,
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0 / count(*), 2) as churn_rate
from telco group by Partner, Dependents order by churn_rate desc;

#high-value customers who churned
select customerID, tenure, round(MonthlyCharges, 2) as monthly_charge,
round(TotalCharges, 2) as lifetime_value, contract, InternetService, TechSupport, OnlineSecurity,
case
when TotalCharges>5000 then 'high value loss'
when TotalCharges>2000 then 'medium value loss'
else 'low value loss'
end as loss_severity from telco where churn='Yes' order by TotalCharges desc limit 100;

#comparison between churned and retained customers
select churn, count(*) as customers,
round(avg(tenure), 1) as avg_tenure,
round(avg(MonthlyCharges), 2) as avg_monthly_charges,
round(avg(TotalCharges), 2) as avg_total_charges,
round(sum(case when contract='Month-to-month' then 1.0 else 0.0 end)/count(*) * 100, 2) as percentage_monthly_contract,
round(sum(case when TechSupport='Yes' then 1.0 else 0.0 end)/count(*) * 100, 2) as percentage_tech_support,
round(sum(case when OnlineSecurity='Yes' then 1.0 else 0.0 end)/count(*) * 100, 2) as percentage_online_security,
round(sum(case when PaymentMethod='Electronic check' then 1.0 else 0.0 end)/count(*) * 100, 2) as percentage_electronic_check from telco group by churn;

#churn by number of services
select
(case when PhoneService='Yes' then 1 else 0 end +
case when InternetService!='No' then 1 else 0 end +
case when OnlineSecurity='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end +
case when TechSupport='Yes' then 1 else 0 end +
case when StreamingTV='Yes' then 1 else 0 end +
case when StreamingMovies='Yes' then 1 else 0 end) as num_services,
count(*) as customers,
sum(case when churn='Yes' then 1 else 0 end) as churned,
round(sum(case when churn='Yes' then 1 else 0 end) * 100.0/count(*), 2) as churn_rate,
round(avg(MonthlyCharges), 2) as avg_monthly_charge,
round(avg(tenure), 1) as avg_tenure from telco group by num_services order by num_services;

#churn risk factors summary
select 'Month-to-Month Contract' as risk_factor, count(*) as affected_customers,
round(avg(case when churn='Yes' then 1.0 else 0.0 end) * 100, 2) as churn_rate,
round(sum(case when churn='Yes' then MonthlyCharges else 0 end), 2) as monthly_revenue_at_risk
from telco where contract='Month-to-month'
union all
select 'No Tech Support', count(*),
round(avg(case when churn='Yes' then 1.0 else 0.0 end) * 100, 2),
round(sum(case when churn='Yes' then MonthlyCharges else 0 end), 2) from telco where OnlineSecurity='No' and InternetService!='No'
union all
select 'Electronic Check Payment', count(*),
round(avg(case when churn='Yes' then 1.0 else 0.0 end) * 100, 2),
round(sum(case when churn='Yes' then MonthlyCharges else 0 end), 2) from telco where PaymentMethod='Electronic check'
union all
select 'Fiber Optic Internet', count(*),
round(avg(case when churn='Yes' then 1.0 else 0.0 end) * 100, 2),
round(sum(case when churn='Yes' then MonthlyCharges else 0 end), 2) from telco where InternetService='Fiber optic'
union all
select 'New Cutomers (<6 months)', count(*),
round(avg(case when churn='Yes' then 1.0 else 0.0 end) * 100, 2),
round(sum(case when churn='Yes' then MonthlyCharges else 0 end), 2) from telco where tenure<6
order by churn_rate desc;
