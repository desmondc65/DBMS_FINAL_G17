SELECT
  i_item_id,
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  SUM(ws_ext_sales_price) AS itemrevenue,
  SUM(ws_ext_sales_price) * 100 / SUM(SUM(ws_ext_sales_price)) OVER (PARTITION BY i_class) AS revenueratio
FROM web_sales AS ws
JOIN item AS i
  ON ws.ws_item_sk = i.i_item_sk
JOIN date_dim AS dd
  ON ws.ws_sold_date_sk = dd.d_date_sk
WHERE
  i.i_category IN ('Jewelry', 'Books', 'Women')
  AND dd.d_date BETWEEN '2002-03-22' AND DATE_ADD('2002-03-22', INTERVAL 30 DAY)
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
;
