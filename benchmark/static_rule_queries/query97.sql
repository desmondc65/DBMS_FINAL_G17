WITH ssci AS (
  SELECT
    ss.ss_customer_sk AS customer_sk,
    ss.ss_item_sk AS item_sk
  FROM store_sales AS ss
  JOIN date_dim AS dd
    ON ss.ss_sold_date_sk = dd.d_date_sk
  WHERE
    dd.d_month_seq BETWEEN 1211 AND 1222
  GROUP BY
    ss.ss_customer_sk,
    ss.ss_item_sk
), csci AS (
  SELECT
    cs.cs_bill_customer_sk AS customer_sk,
    cs.cs_item_sk AS item_sk
  FROM catalog_sales AS cs
  JOIN date_dim AS dd
    ON cs.cs_sold_date_sk = dd.d_date_sk
  WHERE
    dd.d_month_seq BETWEEN 1211 AND 1222
  GROUP BY
    cs.cs_bill_customer_sk,
    cs.cs_item_sk
)
SELECT
  SUM(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NULL THEN 1 ELSE 0 END) AS store_only,
  SUM(CASE WHEN ssci.customer_sk IS NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS catalog_only,
  SUM(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS store_and_catalog
FROM ssci
LEFT JOIN csci
  ON (
    ssci.customer_sk = csci.customer_sk
    AND ssci.item_sk = csci.item_sk
  )
UNION
SELECT
  SUM(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NULL THEN 1 ELSE 0 END) AS store_only,
  SUM(CASE WHEN ssci.customer_sk IS NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS catalog_only,
  SUM(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS store_and_catalog
FROM ssci
RIGHT JOIN csci
  ON (
    ssci.customer_sk = csci.customer_sk
    AND ssci.item_sk = csci.item_sk
  )
LIMIT 100
;
