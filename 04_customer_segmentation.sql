use telco;

#customer value segmentation by lifetime value
select case 
when TotalCharges>=5500 then 'VIP'
when TotalCharges>=3500 then 'high value'
when TotalCharges>=1500 then 'medium value'
else 'low value' end as value_segment, count(*) as customers,
count(*) as customers, round(count(*)*100.0/(select count(*) from telco), 2) as percentage_of_customers,
round(avg(tenure), 1) as avg_tenure, round(avg(MonthlyCharges), 2) as avg_monthly_charge,
round(avg(TotalCharges), 2) as average_lifetime_value,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*)*100, 2) as churn_rate from telco group by value_segment order by average_lifetime_value desc;

#customer segmentation by tenure and monthly charge
select case
when tenure>=48 then 'loyal (4+ years)'
when tenure>=24 then 'established (2-4 years)'
when tenure>=12 then 'growing (1-2 years)'
else 'new (<1 year)' end as lifecycle_stage, case
when MonthlyCharges>=80 then 'premium'
when MonthlyCharges>=50 then 'standard'
else 'basic' end as price_tier, count(*) as customers, round(avg(TotalCharges), 2) as average_lifetime_value,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*) * 100, 2) as churn_rate
from telco group by lifecycle_stage, price_tier order by lifecycle_stage, price_tier;

#demographic segmentation
select case when SeniorCitizen=1 then 'senior' else 'non-senior' end as age_group,
gender, Partner, Dependents, count(*) as customers, round(count(*) *100.0/(select count(*) from telco),2) as percentage_of_base,
round(avg(tenure),1) as average_tenure, round(avg(MonthlyCharges),2) as average_monthly_charge,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*)*100, 2) as churn_rate
from telco group by age_group, gender, Partner, Dependents having count(*)>50 order by churn_rate desc;

#service adaptation segments
select case when(
case when PhoneService='Yes' then 1 else 0 end +
case when InternetService!='No' then 1 else 0 end +
case when OnlineSecurity='Yes' then 1 else 0 end +
case when OnlineBackup='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end +
case when TechSupport='Yes' then 1 else 0 end +
case when StreamingTV='Yes' then 1 else 0 end +
case when StreamingMovies='Yes' then 1 else 0 end) >= 6 then 'power user (6-8 services)'
when(case when PhoneService='Yes' then 1 else 0 end +
case when InternetService!='No' then 1 else 0 end +
case when OnlineSecurity='Yes' then 1 else 0 end +
case when OnlineBackup='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end +
case when TechSupport='Yes' then 1 else 0 end +
case when StreamingTV='Yes' then 1 else 0 end +
case when StreamingMovies='Yes' then 1 else 0 end) >=3 then 'moderate user (3-5 services)'
else 'light user (1-2 services)' end as user_type, count(*) as customers,
round(avg(MonthlyCharges), 2) as average_monthly_charge, round(avg(tenure),1) as average_tenure,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*)*100,2) as churn_rate from telco group by user_type order by churn_rate;

#contract and payment behavior segments
select Contract, PaymentMethod, count(*) as customers, round(count(*) *100.0/(select count(*) from telco),2) as percentage_of_customers,
round(avg(tenure),1) as average_tenure, round(avg(MonthlyCharges),2) as average_monthly_charge,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*)*100, 2) as churn_rate from telco
group by Contract, PaymentMethod having count(*)>50 order by churn_rate desc;

#internet service user segments
select InternetService, case when(
case when OnlineSecurity='Yes' then 1 else 0 end +
case when OnlineBackup='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end) >=3 then 'full protection'
when(case when OnlineSecurity='Yes' then 1 else 0 end +
case when OnlineBackup='Yes' then 1 else 0 end +
case when DeviceProtection='Yes' then 1 else 0 end) >=1 then 'partial protection'
else 'no protection' end as security_level, count(*) as customers, round(avg(MonthlyCharges), 2) as average_monthly_charge,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/ count(*) *100,2) as churn_rate
from telco where InternetService!='No' group by InternetService, security_level order by InternetService, churn_rate desc;

#high-risk customer identification
select customerID, tenure, Contract, round(MonthlyCharges,2) as monthly_charge, round(TotalCharges,2) as lifetime_value,
case when Contract='Month-to-month' then 30 else 0 end +
case when tenure<12 then 20 else 0 end +
case when TechSupport='No' then 15 else 0 end +
case when OnlineSecurity='No' then 13 else 0 end +
case when PaymentMethod= 'Electronic check' then 10 else 0 end +
case when InternetService= 'Fiber optic' then 10 else 0 end as risk_score,
case when (case when Contract='Month-to-month' then 30 else 0 end +
case when tenure<12 then 20 else 0 end +
case when TechSupport='No' then 15 else 0 end +
case when OnlineSecurity='No' then 13 else 0 end +
case when PaymentMethod= 'Electronic check' then 10 else 0 end +
case when InternetService= 'Fiber optic' then 10 else 0 end) >=60 then 'critical risk'
when (case when Contract='Month-to-month' then 30 else 0 end +
case when tenure<12 then 20 else 0 end +
case when TechSupport='No' then 15 else 0 end +
case when OnlineSecurity='No' then 13 else 0 end +
case when PaymentMethod= 'Electronic check' then 10 else 0 end +
case when InternetService= 'Fiber optic' then 10 else 0 end) >=40 then 'high risk'
when (case when Contract='Month-to-month' then 30 else 0 end +
case when tenure<12 then 20 else 0 end +
case when TechSupport='No' then 15 else 0 end +
case when OnlineSecurity='No' then 13 else 0 end +
case when PaymentMethod= 'Electronic check' then 10 else 0 end +
case when InternetService= 'Fiber optic' then 10 else 0 end) >=20 then 'medium risk' else 'low risk' end as risk_category 
from telco where churn='No' order by risk_score desc limit 200;

#price sensitivity by segment
select case when MonthlyCharges<30 then '$0-30'
when MonthlyCharges<50 then '$30-50'
when MonthlyCharges<70 then '$50-70'
when MonthlyCharges<90 then '$70-90'
else '$90+' end as price_range, Contract, count(*) as customers,
round(sum(case when churn='Yes' then 1.0 else 0.0 end)/count(*) * 100, 2) as churn_rate,
round(avg(tenure),1) as average_tenure from telco group by price_range, Contract order by price_range, Contract;