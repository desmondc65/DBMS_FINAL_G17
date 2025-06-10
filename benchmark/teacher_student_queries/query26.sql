WITH DemographicCustomers AS (
    SELECT cd_demo_sk
    FROM customer_demographics
    WHERE cd_gender = 'F'
      AND cd_marital_status = 'M'
      AND cd_education_status = '4 yr Degree'
),
RelevantDates AS (
    SELECT d_date_sk
    FROM date_dim
    WHERE d_year = 2000
),
RelevantPromotions AS (
    SELECT p_promo_sk
    FROM promotion
    WHERE p_channel_email = 'N' OR p_channel_event = 'N'
)
SELECT i_item_id,
       AVG(cs_quantity) AS agg1,
       AVG(cs_list_price) AS agg2,
       AVG(cs_coupon_amt) AS agg3,
       AVG(cs_sales_price) AS agg4
FROM catalog_sales cs
JOIN RelevantDates rd ON cs.cs_sold_date_sk = rd.d_date_sk
JOIN DemographicCustomers dc ON cs.cs_bill_cdemo_sk = dc.cd_demo_sk
JOIN item i ON cs.cs_item_sk = i.i_item_sk
JOIN RelevantPromotions rp ON cs.cs_promo_sk = rp.p_promo_sk
GROUP BY i_item_id
ORDER BY i_item_id
LIMIT 100;
