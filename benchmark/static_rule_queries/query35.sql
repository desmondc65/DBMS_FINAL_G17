SELECT
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  COUNT(*) AS cnt1,
  MAX(cd_dep_count),
  STDDEV_SAMP(cd_dep_count),
  STDDEV_SAMP(cd_dep_count),
  cd_dep_employed_count,
  COUNT(*) AS cnt2,
  MAX(cd_dep_employed_count),
  STDDEV_SAMP(cd_dep_employed_count),
  STDDEV_SAMP(cd_dep_employed_count),
  cd_dep_college_count,
  COUNT(*) AS cnt3,
  MAX(cd_dep_college_count),
  STDDEV_SAMP(cd_dep_college_count),
  STDDEV_SAMP(cd_dep_college_count)
FROM customer AS c
JOIN customer_address AS ca
  ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics AS cd
  ON cd_demo_sk = c.c_current_cdemo_sk
WHERE
  EXISTS(
    SELECT
      1
    FROM store_sales AS ss
    JOIN date_dim AS dd
      ON ss.ss_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = ss.ss_customer_sk AND dd.d_year = 2000 AND dd.d_qoy < 4
  )
  AND (EXISTS(
    SELECT
      1
    FROM web_sales AS ws
    JOIN date_dim AS dd
      ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = ws.ws_bill_customer_sk AND dd.d_year = 2000 AND dd.d_qoy < 4
  ) OR EXISTS(
    SELECT
      1
    FROM catalog_sales AS cs
    JOIN date_dim AS dd
      ON cs.cs_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = cs.cs_ship_customer_sk AND dd.d_year = 2000 AND dd.d_qoy < 4
  ))
GROUP BY
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
ORDER BY
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
LIMIT 100
