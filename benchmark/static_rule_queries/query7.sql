SELECT i_item_id,
       avg(ss_quantity) AS agg1,
       avg(ss_list_price) AS agg2,
       avg(ss_coupon_amt) AS agg3,
       avg(ss_sales_price) AS agg4
FROM store_sales
JOIN customer_demographics ON store_sales.ss_cdemo_sk = customer_demographics.cd_demo_sk
JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
JOIN item ON store_sales.ss_item_sk = item.i_item_sk
JOIN promotion ON store_sales.ss_promo_sk = promotion.p_promo_sk
WHERE customer_demographics.cd_gender = 'M'
  AND customer_demographics.cd_marital_status = 'M'
  AND customer_demographics.cd_education_status = '4 yr Degree'
  AND (promotion.p_channel_email = 'N'
       OR promotion.p_channel_event = 'N')
  AND date_dim.d_year = 2001
GROUP BY i_item_id
ORDER BY i_item_id
LIMIT 100;
