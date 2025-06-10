SELECT
  cd_gender,
  cd_marital_status,
  cd_education_status,
  COUNT(DISTINCT c.c_customer_sk) AS cnt1,
  cd_purchase_estimate,
  COUNT(DISTINCT c.c_customer_sk) AS cnt2,
  cd_credit_rating,
  COUNT(DISTINCT c.c_customer_sk) AS cnt3
FROM customer AS c
JOIN customer_address AS ca
  ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics AS cd
  ON cd.cd_demo_sk = c.c_current_cdemo_sk
WHERE
  ca_state IN ('IN', 'VA', 'MS')
  AND EXISTS(
    SELECT
      1
    FROM store_sales AS ss
    JOIN date_dim AS dd
      ON ss.ss_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = ss.ss_customer_sk
      AND dd.d_year = 2002
      AND dd.d_moy BETWEEN 2 AND 4
  )
  AND NOT EXISTS(
    SELECT
      1
    FROM web_sales AS ws
    JOIN date_dim AS dd
      ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = ws.ws_bill_customer_sk
      AND dd.d_year = 2002
      AND dd.d_moy BETWEEN 2 AND 4
  )
  AND NOT EXISTS(
    SELECT
      1
    FROM catalog_sales AS cs
    JOIN date_dim AS dd
      ON cs.cs_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = cs.cs_ship_customer_sk
      AND dd.d_year = 2002
      AND dd.d_moy BETWEEN 2 AND 4
  )
GROUP BY
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating
ORDER BY
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating
LIMIT 100
