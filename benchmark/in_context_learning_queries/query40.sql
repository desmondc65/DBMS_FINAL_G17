SELECT
  w_state,
  i_item_id,
  SUM(CASE WHEN d_date < '2002-05-18' THEN cs_sales_price - COALESCE(cr_refunded_cash, 0) ELSE 0 END) AS sales_before,
  SUM(CASE WHEN d_date >= '2002-05-18' THEN cs_sales_price - COALESCE(cr_refunded_cash, 0) ELSE 0 END) AS sales_after
FROM catalog_sales AS cs
LEFT OUTER JOIN catalog_returns AS cr
  ON cs.cs_order_number = cr.cr_order_number AND cs.cs_item_sk = cr.cr_item_sk
JOIN warehouse AS w
  ON cs.cs_warehouse_sk = w.w_warehouse_sk
JOIN item AS i
  ON cs.cs_item_sk = i.i_item_sk
JOIN date_dim AS dd
  ON cs.cs_sold_date_sk = dd.d_date_sk
WHERE
  i_current_price BETWEEN 0.99 AND 1.49
  AND dd.d_date BETWEEN date_sub('2002-05-18', interval 30 day) AND date_add('2002-05-18', interval 30 day)
GROUP BY
  w_state,
  i_item_id
ORDER BY
  w_state,
  i_item_id
LIMIT 100;
