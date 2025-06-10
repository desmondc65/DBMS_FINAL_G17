SELECT i_brand_id, i_brand, SUM(ss_ext_sales_price) AS ext_price
FROM store_sales ss
JOIN date_dim d ON ss_sold_date_sk = d_date_sk
JOIN item i ON ss_item_sk = i_item_sk
WHERE i_manager_id = 20
AND d_moy = 12
AND d_year = 1998
GROUP BY i_brand, i_brand_id
ORDER BY ext_price DESC, i_brand_id
LIMIT 100;
