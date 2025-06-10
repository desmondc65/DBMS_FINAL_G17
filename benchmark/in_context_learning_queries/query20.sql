SELECT
  i_item_id,
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  SUM(cs_ext_sales_price) AS itemrevenue,
  SUM(cs_ext_sales_price) * 100 / SUM(SUM(cs_ext_sales_price)) OVER (PARTITION BY i_class) AS revenueratio
FROM catalog_sales AS cs
JOIN item AS i
  ON cs_item_sk = i_item_sk
JOIN date_dim AS d
  ON cs_sold_date_sk = d_date_sk
WHERE
  i_category IN ('Children', 'Sports', 'Music')
  AND d_date BETWEEN CAST('2002-04-01' AS DATE) AND DATE_ADD(CAST('2002-04-01' AS DATE), INTERVAL 30 DAY)
GROUP BY
  i_item_id,
  i_item_desc,
  i_category,
  i_class,
  i_current_price
ORDER BY
  i_category,
  i_class,
  i_item_id,
  i_item_desc,
  revenueratio
LIMIT 100
