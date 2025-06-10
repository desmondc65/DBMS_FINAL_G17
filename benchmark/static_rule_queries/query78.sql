WITH ws AS (
  SELECT
    d_year AS ws_sold_year,
    ws_item_sk,
    ws_bill_customer_sk AS ws_customer_sk,
    SUM(ws_quantity) AS ws_qty,
    SUM(ws_wholesale_cost) AS ws_wc,
    SUM(ws_sales_price) AS ws_sp
  FROM web_sales
  JOIN date_dim
    ON ws_sold_date_sk = d_date_sk
  WHERE
    NOT EXISTS(
      SELECT
        1
      FROM web_returns
      WHERE
        wr_order_number = ws_order_number AND ws_item_sk = wr_item_sk
    )
  GROUP BY
    d_year,
    ws_item_sk,
    ws_bill_customer_sk
), cs AS (
  SELECT
    d_year AS cs_sold_year,
    cs_item_sk,
    cs_bill_customer_sk AS cs_customer_sk,
    SUM(cs_quantity) AS cs_qty,
    SUM(cs_wholesale_cost) AS cs_wc,
    SUM(cs_sales_price) AS cs_sp
  FROM catalog_sales
  JOIN date_dim
    ON cs_sold_date_sk = d_date_sk
  WHERE
    NOT EXISTS(
      SELECT
        1
      FROM catalog_returns
      WHERE
        cr_order_number = cs_order_number AND cs_item_sk = cr_item_sk
    )
  GROUP BY
    d_year,
    cs_item_sk,
    cs_bill_customer_sk
), ss AS (
  SELECT
    d_year AS ss_sold_year,
    ss_item_sk,
    ss_customer_sk,
    SUM(ss_quantity) AS ss_qty,
    SUM(ss_wholesale_cost) AS ss_wc,
    SUM(ss_sales_price) AS ss_sp
  FROM store_sales
  JOIN date_dim
    ON ss_sold_date_sk = d_date_sk
  WHERE
    NOT EXISTS(
      SELECT
        1
      FROM store_returns
      WHERE
        sr_ticket_number = ss_ticket_number AND ss_item_sk = sr_item_sk
    )
  GROUP BY
    d_year,
    ss_item_sk,
    ss_customer_sk
)
SELECT
  ss.ss_customer_sk,
  ROUND(ss.ss_qty / (
    COALESCE(ws.ws_qty, 0) + COALESCE(cs.cs_qty, 0)
  ), 2) AS ratio,
  ss.ss_qty AS store_qty,
  ss.ss_wc AS store_wholesale_cost,
  ss.ss_sp AS store_sales_price,
  COALESCE(ws.ws_qty, 0) + COALESCE(cs.cs_qty, 0) AS other_chan_qty,
  COALESCE(ws.ws_wc, 0) + COALESCE(cs.cs_wc, 0) AS other_chan_wholesale_cost,
  COALESCE(ws.ws_sp, 0) + COALESCE(cs.cs_sp, 0) AS other_chan_sales_price
FROM ss
LEFT JOIN ws
  ON (
    ws.ws_sold_year = ss.ss_sold_year AND ws.ws_item_sk = ss.ss_item_sk AND ws.ws_customer_sk = ss.ss_customer_sk
  )
LEFT JOIN cs
  ON (
    cs.cs_sold_year = ss.ss_sold_year AND cs.cs_item_sk = ss.ss_item_sk AND cs.cs_customer_sk = ss.ss_customer_sk
  )
WHERE
  (
    COALESCE(ws.ws_qty, 0) > 0 OR COALESCE(cs.cs_qty, 0) > 0
  ) AND ss.ss_sold_year = 2001
ORDER BY
  ss.ss_customer_sk,
  ss.ss_qty DESC,
  ss.ss_wc DESC,
  ss.ss_sp DESC,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price,
  ratio
LIMIT 100
