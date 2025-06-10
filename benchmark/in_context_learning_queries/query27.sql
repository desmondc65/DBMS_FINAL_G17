SELECT i_item_id,
       s_state,
       GROUPING(s_state) AS g_state,
       AVG(ss_quantity) AS agg1,
       AVG(ss_list_price) AS agg2,
       AVG(ss_coupon_amt) AS agg3,
       AVG(ss_sales_price) AS agg4
FROM store_sales
JOIN customer_demographics ON store_sales.ss_cdemo_sk = customer_demographics.cd_demo_sk
JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
JOIN store ON store_sales.ss_store_sk = store.s_store_sk
JOIN item ON store_sales.ss_item_sk = item.i_item_sk
WHERE customer_demographics.cd_gender = 'M'
  AND customer_demographics.cd_marital_status = 'U'
  AND customer_demographics.cd_education_status = 'Secondary'
  AND date_dim.d_year = 2000
  AND store.s_state IN ('TN', 'TN', 'TN', 'TN', 'TN', 'TN')
GROUP BY i_item_id,
         s_state WITH ROLLUP
ORDER BY i_item_id,
         s_state
LIMIT 100;
