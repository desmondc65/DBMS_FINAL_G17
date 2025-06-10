SELECT
  cd_gender,
  cd_marital_status,
  cd_education_status,
  COUNT(*) AS cnt1,
  cd_purchase_estimate,
  COUNT(*) AS cnt2,
  cd_credit_rating,
  COUNT(*) AS cnt3,
  cd_dep_count,
  COUNT(*) AS cnt4,
  cd_dep_employed_count,
  COUNT(*) AS cnt5,
  cd_dep_college_count,
  COUNT(*) AS cnt6
FROM customer AS c
JOIN customer_address AS ca
  ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics AS cd
  ON cd.cd_demo_sk = c.c_current_cdemo_sk
WHERE
  ca.ca_county IN ('Clinton County', 'Platte County', 'Franklin County', 'Louisa County', 'Harmon County')
  AND EXISTS(
    SELECT
      1
    FROM store_sales AS ss
    JOIN date_dim AS dd
      ON ss.ss_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = ss.ss_customer_sk
      AND dd.d_year = 2002
      AND dd.d_moy BETWEEN 3 AND 6
  )
  AND (EXISTS(
    SELECT
      1
    FROM web_sales AS ws
    JOIN date_dim AS dd
      ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = ws.ws_bill_customer_sk
      AND dd.d_year = 2002
      AND dd.d_moy BETWEEN 3 AND 6
  ) OR EXISTS(
    SELECT
      1
    FROM catalog_sales AS cs
    JOIN date_dim AS dd
      ON cs.cs_sold_date_sk = dd.d_date_sk
    WHERE
      c.c_customer_sk = cs.cs_ship_customer_sk
      AND dd.d_year = 2002
      AND dd.d_moy BETWEEN 3 AND 6
  ))
GROUP BY
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
ORDER BY
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
LIMIT 100
