SELECT
  SUBSTR(w_warehouse_name, 1, 20),
  sm_type,
  cc_name,
  SUM(CASE WHEN (
    cs_ship_date_sk - cs_sold_date_sk <= 30
  ) THEN 1 ELSE 0 END) AS "30 days",
  SUM(CASE WHEN (
    cs_ship_date_sk - cs_sold_date_sk > 30
  ) AND (
    cs_ship_date_sk - cs_sold_date_sk <= 60
  ) THEN 1 ELSE 0 END) AS "31-60 days",
  SUM(CASE WHEN (
    cs_ship_date_sk - cs_sold_date_sk > 60
  ) AND (
    cs_ship_date_sk - cs_sold_date_sk <= 90
  ) THEN 1 ELSE 0 END) AS "61-90 days",
  SUM(CASE WHEN (
    cs_ship_date_sk - cs_sold_date_sk > 90
  ) AND (
    cs_ship_date_sk - cs_sold_date_sk <= 120
  ) THEN 1 ELSE 0 END) AS "91-120 days",
  SUM(CASE WHEN (
    cs_ship_date_sk - cs_sold_date_sk > 120
  ) THEN 1 ELSE 0 END) AS ">120 days"
FROM catalog_sales AS CS
JOIN warehouse AS W
  ON CS.cs_warehouse_sk = W.w_warehouse_sk
JOIN ship_mode AS SM
  ON CS.cs_ship_mode_sk = SM.sm_ship_mode_sk
JOIN call_center AS CC
  ON CS.cs_call_center_sk = CC.cc_call_center_sk
JOIN date_dim AS DD
  ON CS.cs_ship_date_sk = DD.d_date_sk
WHERE
  DD.d_month_seq BETWEEN 1188 AND 1199
GROUP BY
  SUBSTR(w_warehouse_name, 1, 20),
  sm_type,
  cc_name
ORDER BY
  SUBSTR(w_warehouse_name, 1, 20),
  sm_type,
  cc_name
LIMIT 100
