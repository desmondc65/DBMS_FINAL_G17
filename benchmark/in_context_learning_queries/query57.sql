WITH v1 AS (
  SELECT
    i.i_category,
    i.i_brand,
    cc.cc_name,
    d.d_year,
    d.d_moy,
    SUM(cs.cs_sales_price) AS sum_sales,
    AVG(SUM(cs.cs_sales_price)) OVER (PARTITION BY i.i_category, i.i_brand, cc.cc_name, d.d_year) AS avg_monthly_sales,
    RANK() OVER (PARTITION BY i.i_category, i.i_brand, cc.cc_name ORDER BY d.d_year, d.d_moy) AS rn
  FROM item AS i
  JOIN catalog_sales AS cs
    ON i.i_item_sk = cs.cs_item_sk
  JOIN date_dim AS d
    ON cs.cs_sold_date_sk = d.d_date_sk
  JOIN call_center AS cc
    ON cc.cc_call_center_sk = cs.cs_call_center_sk
  WHERE
    d.d_year IN (2000, 1999, 2001)
    AND (
      d.d_year = 2000
      OR (
        d.d_year = 1999
        AND d.d_moy = 12
      )
      OR (
        d.d_year = 2001
        AND d.d_moy = 1
      )
    )
  GROUP BY
    i.i_category,
    i.i_brand,
    cc.cc_name,
    d.d_year,
    d.d_moy
), v2 AS (
  SELECT
    v1.cc_name,
    v1.d_year,
    v1.d_moy,
    v1.avg_monthly_sales,
    v1.sum_sales,
    v1_lag.sum_sales AS psum,
    v1_lead.sum_sales AS nsum
  FROM v1
  LEFT JOIN v1 AS v1_lag
    ON v1.i_category = v1_lag.i_category
    AND v1.i_brand = v1_lag.i_brand
    AND v1.cc_name = v1_lag.cc_name
    AND v1.rn = v1_lag.rn + 1
  LEFT JOIN v1 AS v1_lead
    ON v1.i_category = v1_lead.i_category
    AND v1.i_brand = v1_lead.i_brand
    AND v1.cc_name = v1_lead.cc_name
    AND v1.rn = v1_lead.rn - 1
)
SELECT
  v2.*
FROM v2
WHERE
  v2.d_year = 2000
  AND v2.avg_monthly_sales > 0
  AND CASE
    WHEN v2.avg_monthly_sales > 0
    THEN ABS(v2.sum_sales - v2.avg_monthly_sales) / v2.avg_monthly_sales
    ELSE NULL
  END > 0.1
ORDER BY
  v2.sum_sales - v2.avg_monthly_sales,
  v2.psum
LIMIT 100
