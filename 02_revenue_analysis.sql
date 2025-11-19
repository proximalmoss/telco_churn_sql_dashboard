use telco;

#overall revenue metrices
select
count(distinct customerID) as total_customers,
round(sum(MonthlyCharges),2) as total_monthly,
round(avg(MonthlyCharges), 2) as avg_revenue_per_customer,
round(sum(TotalCharges),2) as total_revenue,
round(avg(TotalCharges),2) as avg_customer_revenue from telco;

#revenue by contract type
select contract, count(*) as customer_count,
round(sum(MonthlyCharges), 2) as monthly_revenue,
round(avg(MonthlyCharges), 2) as avg_monthly_charge,
round(sum(TotalCharges), 2) as total_revenue,
round(sum(MonthlyCharges) * 100.0/ sum(sum(MonthlyCharges)) over(), 2) as percentage_of_revenue
from telco group by contract order by monthly_revenue desc;

#revenue by tenure
select case when tenure<=12 then '0-1 year'
when tenure<=24 then '1-2 years'
when tenure<=36 then '2-3 years'
when tenure<=48 then '3-4 years'
else '4+ years' end as tenure_group,
count(*) as customers, round(sum(MonthlyCharges), 2) as monthly_revenue,
round(avg(MonthlyCharges), 2) as avg_monthly_revenue,
round(avg(tenure), 1) as avg_tenure_months from telco where churn='No' group by tenure_group
order by
case tenure_group
when '0-1 year' then 1
when '1-2 years' then 2
when '2-3 years' then 3
when '3-4 years' then 4
else 5 end;

#revenue at risk from churn
select churn, count(*) as customers, round(sum(MonthlyCharges), 2) as monthly_revenue,
round(avg(MonthlyCharges), 2) as avg_monthly_charge, round(sum(TotalCharges), 2) as total_revenue_impact,
round(sum(MonthlyCharges) *12, 2) as annualized_revenue from telco group by churn;

#revenue by internet service type
select InternetService, count(*) as customers, round(sum(MonthlyCharges), 2) as total_monthly_revenue,
round(avg(MonthlyCharges), 2) as avg_revenue_per_customer,
round(sum(MonthlyCharges) * 100.0 / sum(sum(MonthlyCharges)) over(), 2) as revenue_share_percentage
from telco group by InternetService order by total_monthly_revenue desc;

#revenue by payment method
select PaymentMethod, count(*) as customers, round(sum(MonthlyCharges), 2) as total_monthly_revenue,
round(avg(MonthlyCharges), 2) as avg_monthly_charge,
round(sum(TotalCharges), 2) as total_revenue from telco group by Paymentmethod order by total_monthly_revenue desc;

#highest value customers
select customerID, tenure, contract, round(MonthlyCharges, 2) as monthly_charge,
round(TotalCharges, 2) as total_value, churn,
case
when TotalCharges>=7000 then 'VIP'
when TotalCharges>=4000 then 'high value'
when TotalCharges>=2000 then 'medium value'
else 'standard' end as customer_tier from telco order by TotalCharges desc limit 100;

#monthly revenue by price range
select case 
when MonthlyCharges < 30 then '$0-30'
when MonthlyCharges < 50 then '$30-50'
when MonthlyCharges < 70 then '$50-70'
when MonthlyCharges < 90 then '$70-90' else '$90+' end as price_range,
count(*) as customers, round(sum(MonthlyCharges), 2) as total_revenue, round(avg(TotalCharges), 2) as avg_total_revenue
from telco group by price_range order by 
case price_range
when '$0-30' then 1
when '$30-50' then 2
when '$50-70' then 3
when '$70-90' then 4 else 5 end;