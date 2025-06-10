WITH ss_items AS (
  SELECT
    i.i_item_id AS item_id,
    SUM(ss.ss_ext_sales_price) AS ss_item_rev
  FROM store_sales AS ss
  JOIN item AS i
    ON ss.ss_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON ss.ss_sold_date_sk = dd.d_date_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM date_dim AS d
      WHERE
        d.d_date = '2000-02-12'
        AND dd.d_week_seq = d.d_week_seq
    )
  GROUP BY
    i.i_item_id
), cs_items AS (
  SELECT
    i.i_item_id AS item_id,
    SUM(cs.cs_ext_sales_price) AS cs_item_rev
  FROM catalog_sales AS cs
  JOIN item AS i
    ON cs.cs_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON cs.cs_sold_date_sk = dd.d_date_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM date_dim AS d
      WHERE
        d.d_date = '2000-02-12'
        AND dd.d_week_seq = d.d_week_seq
    )
  GROUP BY
    i.i_item_id
), ws_items AS (
  SELECT
    i.i_item_id AS item_id,
    SUM(ws.ws_ext_sales_price) AS ws_item_rev
  FROM web_sales AS ws
  JOIN item AS i
    ON ws.ws_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON ws.ws_sold_date_sk = dd.d_date_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM date_dim AS d
      WHERE
        d.d_date = '2000-02-12'
        AND dd.d_week_seq = d.d_week_seq
    )
  GROUP BY
    i.i_item_id
)
SELECT
  ss_items.item_id,
  ss_items.ss_item_rev,
  ss_items.ss_item_rev / ((
    ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev
  ) / 3) * 100 AS ss_dev,
  cs_items.cs_item_rev,
  cs_items.cs_item_rev / ((
    ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev
  ) / 3) * 100 AS cs_dev,
  ws_items.ws_item_rev,
  ws_items.ws_item_rev / ((
    ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev
  ) / 3) * 100 AS ws_dev,
  (
    ss_items.ss_item_rev + cs_items.cs_item_rev + ws_items.ws_item_rev
  ) / 3 AS average
FROM ss_items
JOIN cs_items
  ON ss_items.item_id = cs_items.item_id
JOIN ws_items
  ON ss_items.item_id = ws_items.item_id
WHERE
  ss_items.ss_item_rev BETWEEN 0.9 * cs_items.cs_item_rev AND 1.1 * cs_items.cs_item_rev
  AND ss_items.ss_item_rev BETWEEN 0.9 * ws_items.ws_item_rev AND 1.1 * ws_items.ws_item_rev
  AND cs_items.cs_item_rev BETWEEN 0.9 * ss_items.ss_item_rev AND 1.1 * ss_items.ss_item_rev
  AND cs_items.cs_item_rev BETWEEN 0.9 * ws_items.ws_item_rev AND 1.1 * ws_items.ws_item_rev
  AND ws_items.ws_item_rev BETWEEN 0.9 * ss_items.ss_item_rev AND 1.1 * ss_items.ss_item_rev
  AND ws_items.ws_item_rev BETWEEN 0.9 * cs_items.cs_item_rev AND 1.1 * cs_items.cs_item_rev
ORDER BY
  item_id,
  ss_item_rev
LIMIT 100
