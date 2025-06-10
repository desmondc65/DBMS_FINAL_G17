WITH SalesDelay AS (
    SELECT
        cs.cs_warehouse_sk,
        cs.cs_ship_mode_sk,
        cs.cs_call_center_sk,
        d.d_month_seq,
        (cs.cs_ship_date_sk - cs.cs_sold_date_sk) AS ship_delay
    FROM
        catalog_sales cs
    JOIN
        date_dim d ON cs.cs_ship_date_sk = d.d_date_sk
    WHERE
        d.d_month_seq BETWEEN 1188 AND 1199  -- Optimized date filtering
)
SELECT
    substr(w.w_warehouse_name, 1, 20),
    sm.sm_type,
    cc.cc_name,
    SUM(CASE WHEN sd.ship_delay <= 30 THEN 1 ELSE 0 END) AS "30 days",
    SUM(CASE WHEN sd.ship_delay > 30 AND sd.ship_delay <= 60 THEN 1 ELSE 0 END) AS "31-60 days",
    SUM(CASE WHEN sd.ship_delay > 60 AND sd.ship_delay <= 90 THEN 1 ELSE 0 END) AS "61-90 days",
    SUM(CASE WHEN sd.ship_delay > 90 AND sd.ship_delay <= 120 THEN 1 ELSE 0 END) AS "91-120 days",
    SUM(CASE WHEN sd.ship_delay > 120 THEN 1 ELSE 0 END) AS ">120 days"
FROM
    SalesDelay sd
JOIN
    warehouse w ON sd.cs_warehouse_sk = w.w_warehouse_sk
JOIN
    ship_mode sm ON sd.cs_ship_mode_sk = sm.sm_ship_mode_sk
JOIN
    call_center cc ON sd.cs_call_center_sk = cc.cc_call_center_sk
GROUP BY
    substr(w.w_warehouse_name, 1, 20),
    sm.sm_type,
    cc.cc_name
ORDER BY
    substr(w.w_warehouse_name, 1, 20),
    sm.sm_type,
    cc.cc_name
LIMIT 100;
