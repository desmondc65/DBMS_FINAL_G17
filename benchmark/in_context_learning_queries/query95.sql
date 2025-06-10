SELECT count(DISTINCT ws1.ws_order_number) AS "order count", sum(ws1.ws_ext_ship_cost) AS "total shipping cost", sum(ws1.ws_net_profit) AS "total net profit"
FROM web_sales ws1
JOIN date_dim ON ws1.ws_ship_date_sk = d_date_sk
JOIN customer_address ON ws1.ws_ship_addr_sk = ca_address_sk
JOIN web_site ON ws1.ws_web_site_sk = web_site_sk
WHERE d_date BETWEEN '2002-05-01' AND date_add(CAST('2002-05-01' AS DATE), INTERVAL 60 DAY)
AND ca_state = 'MA'
AND web_company_name = 'pri'
AND EXISTS (
    SELECT 1
    FROM ws_wh
    WHERE ws1.ws_order_number = ws_wh.ws_order_number
)
AND EXISTS (
    SELECT 1
    FROM web_returns wr
    JOIN ws_wh ON wr.wr_order_number = ws_wh.ws_order_number
    WHERE ws1.ws_order_number = wr.wr_order_number
)
ORDER BY count(DISTINCT ws1.ws_order_number)
LIMIT 100;
