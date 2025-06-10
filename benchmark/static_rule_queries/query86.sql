SELECT
  SUM(ws_net_paid) AS total_sum,
  i_category,
  i_class,
  GROUPING(i_category) + GROUPING(i_class) AS lochierarchy,
  RANK() OVER (PARTITION BY GROUPING(i_category) + GROUPING(i_class), CASE WHEN GROUPING(i_class) = 0 THEN i_category END ORDER BY SUM(ws_net_paid) DESC) AS rank_within_parent
FROM web_sales AS ws
JOIN date_dim AS d1
  ON d1.d_date_sk = ws.ws_sold_date_sk
JOIN item AS i
  ON i.i_item_sk = ws.ws_item_sk
WHERE
  d1.d_month_seq BETWEEN 1205 AND 1216
GROUP BY
  i_category,
  i_class
WITH ROLLUP
ORDER BY
  lochierarchy DESC,
  CASE WHEN lochierarchy = 0 THEN i_category END,
  rank_within_parent
LIMIT 100
