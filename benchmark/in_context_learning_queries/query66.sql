SELECT
  w_warehouse_name,
  w_warehouse_sq_ft,
  w_city,
  w_county,
  w_state,
  w_country,
  ship_carriers,
  year,
  SUM(jan_sales) AS jan_sales,
  SUM(feb_sales) AS feb_sales,
  SUM(mar_sales) AS mar_sales,
  SUM(apr_sales) AS apr_sales,
  SUM(may_sales) AS may_sales,
  SUM(jun_sales) AS jun_sales,
  SUM(jul_sales) AS jul_sales,
  SUM(aug_sales) AS aug_sales,
  SUM(sep_sales) AS sep_sales,
  SUM(oct_sales) AS oct_sales,
  SUM(nov_sales) AS nov_sales,
  SUM(dec_sales) AS dec_sales,
  SUM(jan_sales / w_warehouse_sq_ft) AS jan_sales_per_sq_foot,
  SUM(feb_sales / w_warehouse_sq_ft) AS feb_sales_per_sq_foot,
  SUM(mar_sales / w_warehouse_sq_ft) AS mar_sales_per_sq_foot,
  SUM(apr_sales / w_warehouse_sq_ft) AS apr_sales_per_sq_foot,
  SUM(may_sales / w_warehouse_sq_ft) AS may_sales_per_sq_foot,
  SUM(jun_sales / w_warehouse_sq_ft) AS jun_sales_per_sq_foot,
  SUM(jul_sales / w_warehouse_sq_ft) AS jul_sales_per_sq_foot,
  SUM(aug_sales / w_warehouse_sq_ft) AS aug_sales_per_sq_foot,
  SUM(sep_sales / w_warehouse_sq_ft) AS sep_sales_per_sq_foot,
  SUM(oct_sales / w_warehouse_sq_ft) AS oct_sales_per_sq_foot,
  SUM(nov_sales / w_warehouse_sq_ft) AS nov_sales_per_sq_foot,
  SUM(dec_sales / w_warehouse_sq_ft) AS dec_sales_per_sq_foot,
  SUM(jan_net) AS jan_net,
  SUM(feb_net) AS feb_net,
  SUM(mar_net) AS mar_net,
  SUM(apr_net) AS apr_net,
  SUM(may_net) AS may_net,
  SUM(jun_net) AS jun_net,
  SUM(jul_net) AS jul_net,
  SUM(aug_net) AS aug_net,
  SUM(sep_net) AS sep_net,
  SUM(oct_net) AS oct_net,
  SUM(nov_net) AS nov_net,
  SUM(dec_net) AS dec_net
FROM (
  SELECT
    w.w_warehouse_name,
    w.w_warehouse_sq_ft,
    w.w_city,
    w.w_county,
    w.w_state,
    w.w_country,
    'FEDEX,GERMA' AS ship_carriers,
    d.d_year AS year,
    SUM(CASE WHEN d.d_moy = 1 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS jan_sales,
    SUM(CASE WHEN d.d_moy = 2 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS feb_sales,
    SUM(CASE WHEN d.d_moy = 3 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS mar_sales,
    SUM(CASE WHEN d.d_moy = 4 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS apr_sales,
    SUM(CASE WHEN d.d_moy = 5 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS may_sales,
    SUM(CASE WHEN d.d_moy = 6 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS jun_sales,
    SUM(CASE WHEN d.d_moy = 7 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS jul_sales,
    SUM(CASE WHEN d.d_moy = 8 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS aug_sales,
    SUM(CASE WHEN d.d_moy = 9 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS sep_sales,
    SUM(CASE WHEN d.d_moy = 10 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS oct_sales,
    SUM(CASE WHEN d.d_moy = 11 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS nov_sales,
    SUM(CASE WHEN d.d_moy = 12 THEN ws.ws_ext_list_price * ws.ws_quantity ELSE 0 END) AS dec_sales,
    SUM(CASE WHEN d.d_moy = 1 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS jan_net,
    SUM(CASE WHEN d.d_moy = 2 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS feb_net,
    SUM(CASE WHEN d.d_moy = 3 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS mar_net,
    SUM(CASE WHEN d.d_moy = 4 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS apr_net,
    SUM(CASE WHEN d.d_moy = 5 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS may_net,
    SUM(CASE WHEN d.d_moy = 6 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS jun_net,
    SUM(CASE WHEN d.d_moy = 7 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS jul_net,
    SUM(CASE WHEN d.d_moy = 8 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS aug_net,
    SUM(CASE WHEN d.d_moy = 9 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS sep_net,
    SUM(CASE WHEN d.d_moy = 10 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS oct_net,
    SUM(CASE WHEN d.d_moy = 11 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS nov_net,
    SUM(CASE WHEN d.d_moy = 12 THEN ws.ws_net_profit * ws.ws_quantity ELSE 0 END) AS dec_net
  FROM web_sales AS ws
  JOIN warehouse AS w
    ON ws.ws_warehouse_sk = w.w_warehouse_sk
  JOIN date_dim AS d
    ON ws.ws_sold_date_sk = d.d_date_sk
  JOIN time_dim AS t
    ON ws.ws_sold_time_sk = t.t_time_sk
  JOIN ship_mode AS sm
    ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk
  WHERE
    d.d_year = 2001
    AND t.t_time BETWEEN 19072 AND 19072 + 28800
    AND sm.sm_carrier IN ('FEDEX', 'GERMA')
  GROUP BY
    w.w_warehouse_name,
    w.w_warehouse_sq_ft,
    w.w_city,
    w.w_county,
    w.w_state,
    w.w_country,
    d.d_year
  UNION ALL
  SELECT
    w.w_warehouse_name,
    w.w_warehouse_sq_ft,
    w.w_city,
    w.w_county,
    w.w_state,
    w.w_country,
    'FEDEX,GERMA' AS ship_carriers,
    d.d_year AS year,
    SUM(CASE WHEN d.d_moy = 1 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS jan_sales,
    SUM(CASE WHEN d.d_moy = 2 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS feb_sales,
    SUM(CASE WHEN d.d_moy = 3 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS mar_sales,
    SUM(CASE WHEN d.d_moy = 4 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS apr_sales,
    SUM(CASE WHEN d.d_moy = 5 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS may_sales,
    SUM(CASE WHEN d.d_moy = 6 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS jun_sales,
    SUM(CASE WHEN d.d_moy = 7 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS jul_sales,
    SUM(CASE WHEN d.d_moy = 8 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS aug_sales,
    SUM(CASE WHEN d.d_moy = 9 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS sep_sales,
    SUM(CASE WHEN d.d_moy = 10 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS oct_sales,
    SUM(CASE WHEN d.d_moy = 11 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS nov_sales,
    SUM(CASE WHEN d.d_moy = 12 THEN cs.cs_sales_price * cs.cs_quantity ELSE 0 END) AS dec_sales,
    SUM(CASE WHEN d.d_moy = 1 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS jan_net,
    SUM(CASE WHEN d.d_moy = 2 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS feb_net,
    SUM(CASE WHEN d.d_moy = 3 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS mar_net,
    SUM(CASE WHEN d.d_moy = 4 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS apr_net,
    SUM(CASE WHEN d.d_moy = 5 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS may_net,
    SUM(CASE WHEN d.d_moy = 6 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS jun_net,
    SUM(CASE WHEN d.d_moy = 7 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS jul_net,
    SUM(CASE WHEN d.d_moy = 8 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS aug_net,
    SUM(CASE WHEN d.d_moy = 9 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS sep_net,
    SUM(CASE WHEN d.d_moy = 10 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS oct_net,
    SUM(CASE WHEN d.d_moy = 11 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS nov_net,
    SUM(CASE WHEN d.d_moy = 12 THEN cs.cs_net_paid * cs.cs_quantity ELSE 0 END) AS dec_net
  FROM catalog_sales AS cs
  JOIN warehouse AS w
    ON cs.cs_warehouse_sk = w.w_warehouse_sk
  JOIN date_dim AS d
    ON cs.cs_sold_date_sk = d.d_date_sk
  JOIN time_dim AS t
    ON cs.cs_sold_time_sk = t.t_time_sk
  JOIN ship_mode AS sm
    ON cs.cs_ship_mode_sk = sm.sm_ship_mode_sk
  WHERE
    d.d_year = 2001
    AND t.t_time BETWEEN 19072 AND 19072 + 28800
    AND sm.sm_carrier IN ('FEDEX', 'GERMA')
  GROUP BY
    w.w_warehouse_name,
    w.w_warehouse_sq_ft,
    w.w_city,
    w.w_county,
    w.w_state,
    w.w_country,
    d.d_year
) AS x
GROUP BY
  w_warehouse_name,
  w_warehouse_sq_ft,
  w_city,
  w_county,
  w_state,
  w_country,
  ship_carriers,
  year
ORDER BY
  w_warehouse_name
LIMIT 100
