SELECT
    COUNT(DISTINCT cs.cs_order_number) AS "order count",
    SUM(cs.cs_ext_ship_cost) AS "total shipping cost",
    SUM(cs.cs_net_profit) AS "total net profit"
FROM
    catalog_sales cs
JOIN
    date_dim d ON cs.cs_ship_date_sk = d.d_date_sk
JOIN
    customer_address ca ON cs.cs_ship_addr_sk = ca.ca_address_sk
JOIN
    call_center cc ON cs.cs_call_center_sk = cc.cc_call_center_sk
WHERE
    d.d_date BETWEEN '1999-05-01' AND DATE_ADD(CAST('1999-05-01' AS DATE), INTERVAL 60 DAY)
    AND ca.ca_state = 'ID'
    AND cc.cc_county = 'Williamson County'
    AND EXISTS (
        SELECT 1
        FROM catalog_sales cs2
        WHERE cs.cs_order_number = cs2.cs_order_number
          AND cs.cs_warehouse_sk <> cs2.cs_warehouse_sk
    )
    AND NOT EXISTS (
        SELECT 1
        FROM catalog_returns cr
        WHERE cs.cs_order_number = cr.cr_order_number
    )
ORDER BY
    "order count"
LIMIT 100;