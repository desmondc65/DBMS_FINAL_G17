SELECT i_brand_id, i_brand, i_manufact_id, i_manufact, sum(ss_ext_sales_price) AS ext_price
FROM store_sales
JOIN date_dim ON ss_sold_date_sk = d_date_sk
JOIN item ON ss_item_sk = i_item_sk
JOIN customer ON ss_customer_sk = c_customer_sk
JOIN customer_address ON c_current_addr_sk = ca_address_sk
JOIN store ON ss_store_sk = s_store_sk
WHERE i_manager_id = 8
AND d_moy = 11
AND d_year = 1999
AND substr(ca_zip, 1, 5) <> substr(s_zip, 1, 5)
GROUP BY i_brand_id, i_brand, i_manufact_id, i_manufact
ORDER BY ext_price DESC, i_brand, i_brand_id, i_manufact_id, i_manufact
LIMIT 100;
