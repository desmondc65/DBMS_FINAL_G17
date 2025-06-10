SELECT
  dt.d_year,
  item.i_brand_id,
  item.i_brand,
  SUM(ss_ext_sales_price)
FROM store_sales AS store_sales
INNER JOIN date_dim AS dt
  ON dt.d_date_sk = store_sales.ss_sold_date_sk
INNER JOIN item AS item
  ON store_sales.ss_item_sk = item.i_item_sk
WHERE
  item.i_manager_id = 1
  AND dt.d_moy = 11
  AND dt.d_year = 2000
GROUP BY
  dt.d_year,
  item.i_brand,
  item.i_brand_id
ORDER BY
  dt.d_year,
  SUM(ss_ext_sales_price) DESC,
  item.i_brand_id
LIMIT 100
