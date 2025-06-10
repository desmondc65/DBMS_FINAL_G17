SELECT
  SUBSTR(w.w_warehouse_name, 1, 20),
  sm.sm_type,
  cc.cc_name,
  SUM(CASE WHEN (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk <= 30
  ) THEN 1 ELSE 0 END) AS "30 days",
  SUM(CASE WHEN (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk > 30
  ) AND (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk <= 60
  ) THEN 1 ELSE 0 END) AS "31-60 days",
  SUM(CASE WHEN (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk > 60
  ) AND (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk <= 90
  ) THEN 1 ELSE 0 END) AS "61-90 days",
  SUM(CASE WHEN (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk > 90
  ) AND (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk <= 120
  ) THEN 1 ELSE 0 END) AS "91-120 days",
  SUM(CASE WHEN (
    cs.cs_ship_date_sk - cs.cs_sold_date_sk > 120
  ) THEN 1 ELSE 0 END) AS ">120 days"
FROM catalog_sales AS cs
JOIN warehouse AS w
  ON cs.cs_warehouse_sk = w.w_warehouse_sk
JOIN ship_mode AS sm
  ON cs.cs_ship_mode_sk = sm.sm_ship_mode_sk
JOIN call_center AS cc
  ON cs.cs_call_center_sk = cc.cc_call_center_sk
JOIN date_dim AS dd
  ON cs.cs_ship_date_sk = dd.d_date_sk
WHERE
  dd.d_month_seq BETWEEN 1188 AND 1199
GROUP BY
  SUBSTR(w.w_warehouse_name, 1, 20),
  sm.sm_type,
  cc.cc_name
ORDER BY
  SUBSTR(w.w_warehouse_name, 1, 20),
  sm.sm_type,
  cc.cc_name
LIMIT 100
;
