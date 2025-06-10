SELECT
    COUNT(DISTINCT ws1.ws_order_number) AS "order count",
    SUM(ws1.ws_ext_ship_cost) AS "total shipping cost",
    SUM(ws1.ws_net_profit) AS "total net profit"
FROM
    web_sales ws1
INNER JOIN
    date_dim d ON ws1.ws_ship_date_sk = d.d_date_sk
INNER JOIN
    customer_address ca ON ws1.ws_ship_addr_sk = ca.ca_address_sk
INNER JOIN
    web_site web ON ws1.ws_web_site_sk = web.web_site_sk
WHERE
    d.d_date BETWEEN '1999-04-01' AND DATE_ADD(CAST('1999-04-01' AS DATE), INTERVAL 60 DAY)
    AND ca.ca_state = 'WI'
    AND web.web_company_name = 'pri'
    AND EXISTS (
        SELECT 1
        FROM web_sales ws2
        WHERE ws1.ws_order_number = ws2.ws_order_number
          AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
    )
    AND NOT EXISTS (
        SELECT 1
        FROM web_returns wr1
        WHERE ws1.ws_order_number = wr1.wr_order_number
    )
ORDER BY
    "order count"
LIMIT 100;
