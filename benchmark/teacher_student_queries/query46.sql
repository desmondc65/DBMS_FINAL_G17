SELECT
    c.c_last_name,
    c.c_first_name,
    ca_current.ca_city,
    dn.bought_city,
    dn.ss_ticket_number,
    dn.amt,
    dn.profit
FROM
    (
        SELECT
            ss_ticket_number,
            ss_customer_sk,
            ca.ca_city AS bought_city,
            SUM(ss_coupon_amt) AS amt,
            SUM(ss_net_profit) AS profit
        FROM
            store_sales ss
        JOIN
            date_dim dd ON ss.ss_sold_date_sk = dd.d_date_sk
        JOIN
            store s ON ss.ss_store_sk = s.s_store_sk
        JOIN
            household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
        JOIN
            customer_address ca ON ss.ss_addr_sk = ca.ca_address_sk
        WHERE
            (hd.hd_dep_count = 3 OR hd.hd_vehicle_count = 1)
            AND dd.d_dow IN (6, 0)
            AND dd.d_year >= 1999 AND dd.d_year <= 2001
            AND s.s_city IN ('Midway', 'Fairview')
        GROUP BY
            ss_ticket_number,
            ss_customer_sk,
            ca.ca_city
    ) dn
JOIN
    customer c ON dn.ss_customer_sk = c.c_customer_sk
JOIN
    customer_address ca_current ON c.c_current_addr_sk = ca_current.ca_address_sk
WHERE
    ca_current.ca_city <> dn.bought_city
ORDER BY
    c.c_last_name,
    c.c_first_name,
    ca_current.ca_city,
    dn.bought_city,
    dn.ss_ticket_number
LIMIT 100
