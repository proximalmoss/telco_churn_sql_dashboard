use telco;
select count(*) as total_rows from telco;
select * from telco limit 20;

#checking datatypes
describe telco;

#checking null values
select 
count(*) as total_rows,
count(customerID) as has_customer_ID,
count(gender) as has_gender,
count(SeniorCitizen) as has_senior_citizen,
count(Partner) as has_partner,
count(Dependents) as has_dependents,
count(tenure) as has_tenure,
count(PhoneService) as has_phone_service,
count(MultipleLines) as has_multiple_lines,
count(InternetService) as has_internet_service,
count(OnlineSecurity) as has_online_security,
count(OnlineBackup) as has_online_backup,
count(DeviceProtection) as has_device_protection,
count(TechSupport) as has_tech_support,
count(StreamingTV) as has_streaming_TV,
count(StreamingMovies) as has_streaming_movies,
count(Contract) as has_contract,
count(PaperlessBilling) as has_paperless_billing,
count(PaymentMethod) as has_payment_method,
count(MonthlyCharges) as has_monthly_charges,
count(TotalCharges) as has_total_charges,
count(churn) as has_churn
from telco;

#more detailed null check
select 'customerid' as column_name, sum(case when customerID is null or customerID='' then 1 else 0 end) as null_count from telco
union all
select 'gender' as column_name, sum(case when gender is null or gender='' then 1 else 0 end) as null_count from telco
union all
select 'senior_citizen' as column_name, sum(case when SeniorCitizen is null then 1 else 0 end) as null_count from telco
union all
select 'partner' as column_name, sum(case when Partner is null or Partner='' then 1 else 0 end) as null_count from telco
union all
select 'dependents' as column_name, sum(case when Dependents is null or Dependents='' then 1 else 0 end) as null_count from telco
union all
select 'tenure' as column_name, sum(case when tenure is null then 1 else 0 end) as null_count from telco
union all
select 'phoneservice' as column_name, sum(case when PhoneService is null or PhoneService='' then 1 else 0 end) as null_count from telco
union all
select 'multiplelines' as column_name, sum(case when MultipleLines is null or MultipleLines='' then 1 else 0 end) as null_count from telco
union all
select 'internetservice' as column_name, sum(case when InternetService is null or InternetService='' then 1 else 0 end) as null_count from telco
union all
select 'onlinesecurity' as column_name, sum(case when OnlineSecurity is null or OnlineSecurity='' then 1 else 0 end) as null_count from telco
union all
select 'onlinebackup' as column_name, sum(case when OnlineBackup is null or OnlineBackup='' then 1 else 0 end) as null_count from telco
union all
select 'deviceprotection' as column_name, sum(case when DeviceProtection is null or DeviceProtection='' then 1 else 0 end) as null_count from telco
union all
select 'streamingtv' as column_name, sum(case when StreamingTV is null or StreamingTV='' then 1 else 0 end) as null_count from telco
union all
select 'streamingmovies' as column_name, sum(case when StreamingMovies is null or StreamingMovies='' then 1 else 0 end) as null_count from telco
union all
select 'contract' as column_name, sum(case when Contract is null or Contract='' then 1 else 0 end) as null_count from telco
union all
select 'paperlessbilling' as column_name, sum(case when PaperlessBilling is null or PaperlessBilling='' then 1 else 0 end) as null_count from telco
union all
select 'paymentmethod' as column_name, sum(case when PaymentMethod is null or PaymentMethod='' then 1 else 0 end) as null_count from telco
union all
select 'monthlycharges' as column_name, sum(case when MonthlyCharges is null then 1 else 0 end) as null_count from telco
union all
select 'totalcharges' as column_name, sum(case when TotalCharges is null then 1 else 0 end) as null_count from telco
union all
select 'churn' as column_name, sum(case when churn is null or churn='' then 1 else 0 end) as null_count from telco;

#checking for duplicate customerID
select count(*) as total_rows, count(distinct customerID) as unique_customers, count(*) - count(distinct customerID) as duplicates from telco;

#checking data ranges
select min(tenure) as min_tenure, max(tenure) as max_tenure, avg(tenure) as avg_tenure from telco;
select * from telco where tenure<0;

select min(MonthlyCharges) as min_charge, max(MonthlyCharges) as max_charge, avg(MonthlyCharges) as avg_charge from telco;
select * from telco where MonthlyCharges<0;

select min(TotalCharges) as min_total, max(TotalCharges) as max_total, avg(TotalCharges) as avg_total from telco;
select * from telco where TotalCharges<0;

#checking categorical values
select distinct gender from telco;
select distinct churn from telco;
select distinct contract from telco;
select distinct InternetService from telco;
select distinct PaymentMethod from telco;

#checking if total charges and monthly chrages * tenure are roughly the same
select customerID, tenure, MonthlyCharges, TotalCharges, round(MonthlyCharges * tenure, 2) as expected_total,
round(TotalCharges - (MonthlyCharges * tenure), 2) as difference from telco limit 20;

select PhoneService, MultipleLines, count(*) as count from telco group by PhoneService, MultipleLines;
#maximum customers have phone service and no multiple lines

select InternetService, OnlineSecurity, OnlineBackup, count(*) as count from telco group by InternetService, OnlineSecurity, OnlineBackup limit 20;
#customers using fiber optic have no online security and backup and are maximum

#churn rate
select churn, count(*) as customers, round(count(*) * 100.0 / (select count(*) from telco), 2) as percentage from telco group by churn;
#low churning rate ~26%

#contract type
select contract, count(*) as customers, round(count(*) * 100.0 / (select count(*) from telco), 2) as pct from telco group by contract order by customers desc;
#maximum customers seem to prefer month to month contract and least amount of cutomers prefer one year contract
