SELECT
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number,
  amt,
  profit
FROM (
  SELECT
    ss_ticket_number,
    ss_customer_sk,
    ca_city AS bought_city,
    SUM(ss_coupon_amt) AS amt,
    SUM(ss_net_profit) AS profit
  FROM store_sales AS ss
  JOIN date_dim AS dd
    ON ss.ss_sold_date_sk = dd.d_date_sk
  JOIN store AS s
    ON ss.ss_store_sk = s.s_store_sk
  JOIN household_demographics AS hd
    ON ss.ss_hdemo_sk = hd.hd_demo_sk
  JOIN customer_address AS ca
    ON ss.ss_addr_sk = ca.ca_address_sk
  WHERE
    (
      hd.hd_dep_count = 3
      OR hd.hd_vehicle_count = 1
    )
    AND dd.d_dow IN (6, 0)
    AND dd.d_year IN (1999, 2000, 2001)
    AND s.s_city IN ('Midway', 'Fairview')
  GROUP BY
    ss_ticket_number,
    ss_customer_sk,
    ca.ca_city
) AS dn
JOIN customer AS c
  ON dn.ss_customer_sk = c.c_customer_sk
JOIN customer_address AS current_addr
  ON c.c_current_addr_sk = current_addr.ca_address_sk
WHERE
  current_addr.ca_city <> bought_city
ORDER BY
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number
LIMIT 100
