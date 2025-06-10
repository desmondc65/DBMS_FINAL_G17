WITH DateFilter AS (
    SELECT d_date_sk
    FROM date_dim
    WHERE d_year = 2001
),
FilteredCustomerDemographics AS (
    SELECT cd_demo_sk
    FROM customer_demographics
    WHERE (cd_marital_status = 'W' AND cd_education_status = '2 yr Degree')
       OR (cd_marital_status = 'S' AND cd_education_status = 'Advanced Degree')
       OR (cd_marital_status = 'D' AND cd_education_status = 'Primary')
),
FilteredCustomerAddress AS (
    SELECT ca_address_sk
    FROM customer_address
    WHERE ca_country = 'United States'
      AND ca_state IN ('IL', 'KY', 'OR', 'VA', 'FL', 'AL', 'OK', 'IA', 'TX')
)
SELECT SUM(ss_quantity)
FROM store_sales ss
JOIN store s ON ss.ss_store_sk = s.s_store_sk
JOIN DateFilter df ON ss.ss_sold_date_sk = df.d_date_sk
JOIN FilteredCustomerDemographics cd ON ss.ss_cdemo_sk = cd.cd_demo_sk
JOIN FilteredCustomerAddress ca ON ss.ss_addr_sk = ca.ca_address_sk
WHERE (
    (ss_cdemo_sk IN (SELECT cd_demo_sk FROM customer_demographics WHERE cd_marital_status = 'W' AND cd_education_status = '2 yr Degree') AND ss_sales_price BETWEEN 100.00 AND 150.00)
    OR
    (ss_cdemo_sk IN (SELECT cd_demo_sk FROM customer_demographics WHERE cd_marital_status = 'S' AND cd_education_status = 'Advanced Degree') AND ss_sales_price BETWEEN 50.00 AND 100.00)
    OR
    (ss_cdemo_sk IN (SELECT cd_demo_sk FROM customer_demographics WHERE cd_marital_status = 'D' AND cd_education_status = 'Primary') AND ss_sales_price BETWEEN 150.00 AND 200.00)
)
AND (
    (ss_addr_sk IN (SELECT ca_address_sk FROM customer_address WHERE ca_country = 'United States' AND ca_state IN ('IL', 'KY', 'OR')) AND ss_net_profit BETWEEN 0 AND 2000)
    OR
    (ss_addr_sk IN (SELECT ca_address_sk FROM customer_address WHERE ca_country = 'United States' AND ca_state IN ('VA', 'FL', 'AL')) AND ss_net_profit BETWEEN 150 AND 3000)
    OR
    (ss_addr_sk IN (SELECT ca_address_sk FROM customer_address WHERE ca_country = 'United States' AND ca_state IN ('OK', 'IA', 'TX')) AND ss_net_profit BETWEEN 50 AND 25000)
)
;