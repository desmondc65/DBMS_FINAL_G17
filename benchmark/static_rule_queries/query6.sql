SELECT ca.ca_state AS state, COUNT(*) AS cnt
FROM customer_address ca
JOIN customer c ON ca.ca_address_sk = c.c_current_addr_sk
JOIN store_sales ss ON c.c_customer_sk = ss.ss_customer_sk
JOIN date_dim dd ON ss.ss_sold_date_sk = dd.d_date_sk
JOIN item i ON ss.ss_item_sk = i.i_item_sk
WHERE dd.d_month_seq = (
    SELECT DISTINCT d_month_seq
    FROM date_dim
    WHERE d_year = 1998 AND d_moy = 3
)
AND i.i_current_price > 1.2 * (
    SELECT AVG(i2.i_current_price)
    FROM item i2
    WHERE i2.i_category = i.i_category
)
GROUP BY ca.ca_state
HAVING COUNT(*) >= 10
ORDER BY cnt, ca.ca_state
LIMIT 100;
