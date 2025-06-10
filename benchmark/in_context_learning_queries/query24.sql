WITH ssales AS (
  SELECT
    c_last_name,
    c_first_name,
    s_store_name,
    SUM(ss_net_profit) AS netpaid
  FROM store_sales AS ss
  JOIN store_returns AS sr
    ON ss.ss_ticket_number = sr.sr_ticket_number
    AND ss.ss_item_sk = sr.sr_item_sk
  JOIN store AS s
    ON ss.ss_store_sk = s.s_store_sk
  JOIN item AS i
    ON ss.ss_item_sk = i.i_item_sk
  JOIN customer AS c
    ON ss.ss_customer_sk = c.c_customer_sk
  JOIN customer_address AS ca
    ON c.c_current_addr_sk = ca.ca_address_sk
  WHERE ss.ss_customer_sk = c.c_customer_sk
  AND ss.ss_item_sk = i.i_item_sk
  AND ss.ss_store_sk = s.s_store_sk
  AND c.c_current_addr_sk = ca.ca_address_sk
  AND c.c_birth_country <> UPPER(ca.ca_country)
  AND s.s_zip = ca.ca_zip
  AND s.s_market_id = 10
  AND i.i_color = 'orchid'
  GROUP BY
    c_last_name,
    c_first_name,
    s_store_name
)
SELECT
  c_last_name,
  c_first_name,
  s_store_name,
  SUM(netpaid) AS paid
FROM ssales
GROUP BY
  c_last_name,
  c_first_name,
  s_store_name
HAVING SUM(netpaid) > (
  SELECT
    0.05 * AVG(netpaid)
  FROM ssales
)
ORDER BY
  c_last_name,
  c_first_name,
  s_store_name
;
WITH ssales AS (
  SELECT
    c_last_name,
    c_first_name,
    s_store_name,
    SUM(ss_net_profit) AS netpaid
  FROM store_sales AS ss
  JOIN store_returns AS sr
    ON ss.ss_ticket_number = sr.sr_ticket_number
    AND ss.ss_item_sk = sr.sr_item_sk
  JOIN store AS s
    ON ss.ss_store_sk = s.s_store_sk
  JOIN item AS i
    ON ss.ss_item_sk = i.i_item_sk
  JOIN customer AS c
    ON ss.ss_customer_sk = c.c_customer_sk
  JOIN customer_address AS ca
    ON c.c_current_addr_sk = ca.ca_address_sk
  WHERE ss.ss_customer_sk = c.c_customer_sk
  AND ss.ss_item_sk = i.i_item_sk
  AND ss.ss_store_sk = s.s_store_sk
  AND c.c_current_addr_sk = ca.ca_address_sk
  AND c.c_birth_country <> UPPER(ca.ca_country)
  AND s.s_zip = ca.ca_zip
  AND s.s_market_id = 10
  AND i.i_color = 'green'
  GROUP BY
    c_last_name,
    c_first_name,
    s_store_name
)
SELECT
  c_last_name,
  c_first_name,
  s_store_name,
  SUM(netpaid) AS paid
FROM ssales
GROUP BY
  c_last_name,
  c_first_name,
  s_store_name
HAVING SUM(netpaid) > (
  SELECT
    0.05 * AVG(netpaid)
  FROM ssales
)
ORDER BY
  c_last_name,
  c_first_name,
  s_store_name
;
