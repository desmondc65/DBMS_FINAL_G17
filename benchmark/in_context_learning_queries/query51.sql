WITH web_v1 AS (
  SELECT
    ws_item_sk AS item_sk,
    d_date,
    SUM(ws_sales_price) OVER (PARTITION BY ws_item_sk ORDER BY d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cume_sales
  FROM web_sales
  JOIN date_dim
    ON ws_sold_date_sk = d_date_sk
  WHERE
    d_month_seq BETWEEN 1215 AND 1226
    AND ws_item_sk IS NOT NULL
  GROUP BY
    ws_item_sk,
    d_date
), store_v1 AS (
  SELECT
    ss_item_sk AS item_sk,
    d_date,
    SUM(ss_sales_price) OVER (PARTITION BY ss_item_sk ORDER BY d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cume_sales
  FROM store_sales
  JOIN date_dim
    ON ss_sold_date_sk = d_date_sk
  WHERE
    d_month_seq BETWEEN 1215 AND 1226
    AND ss_item_sk IS NOT NULL
  GROUP BY
    ss_item_sk,
    d_date
)
SELECT
  y.item_sk,
  y.d_date,
  y.web_sales,
  y.store_sales,
  y.web_cumulative,
  y.store_cumulative
FROM (
  SELECT
    x.item_sk,
    x.d_date,
    x.web_sales,
    x.store_sales,
    MAX(x.web_sales) OVER (PARTITION BY x.item_sk ORDER BY x.d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS web_cumulative,
    MAX(x.store_sales) OVER (PARTITION BY x.item_sk ORDER BY x.d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS store_cumulative
  FROM (
    SELECT
      COALESCE(web.item_sk, store.item_sk) AS item_sk,
      COALESCE(web.d_date, store.d_date) AS d_date,
      web.cume_sales AS web_sales,
      store.cume_sales AS store_sales
    FROM web_v1 AS web
    LEFT JOIN store_v1 AS store
      ON web.item_sk = store.item_sk
      AND web.d_date = store.d_date
    UNION ALL
    SELECT
      COALESCE(web.item_sk, store.item_sk) AS item_sk,
      COALESCE(web.d_date, store.d_date) AS d_date,
      web.cume_sales AS web_sales,
      store.cume_sales AS store_sales
    FROM web_v1 AS web
    RIGHT JOIN store_v1 AS store
      ON web.item_sk = store.item_sk
      AND web.d_date = store.d_date
  ) AS x
) AS y
WHERE
  y.web_cumulative > y.store_cumulative
ORDER BY
  y.item_sk,
  y.d_date
LIMIT 100
