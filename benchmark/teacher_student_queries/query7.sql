SELECT  i_item_id,
        AVG(ss_quantity) AS agg1,
        AVG(ss_list_price) AS agg2,
        AVG(ss_coupon_amt) AS agg3,
        AVG(ss_sales_price) AS agg4
FROM store_sales ss
JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
JOIN item i ON ss.ss_item_sk = i.i_item_sk
JOIN customer_demographics cd ON ss.ss_cdemo_sk = cd.cd_demo_sk
JOIN promotion p ON ss.ss_promo_sk = p.p_promo_sk
WHERE d.d_year = 2001
  AND cd.cd_gender = 'M'
  AND cd.cd_marital_status = 'M'
  AND cd.cd_education_status = '4 yr Degree'
  AND (p.p_channel_email = 'N' OR p.p_channel_event = 'N')
GROUP BY i_item_id
ORDER BY i_item_id
LIMIT 100;
