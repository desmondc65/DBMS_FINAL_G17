WITH CategoryAvgPrice AS (
    SELECT
        i_category,
        AVG(i_current_price) AS avg_price
    FROM
        item
    GROUP BY
        i_category
),
March1998 AS (
    SELECT DISTINCT
        d_date_sk
    FROM
        date_dim
    WHERE
        d_year = 1998
        AND d_moy = 3
)
SELECT
    a.ca_state AS state,
    COUNT(*) AS cnt
FROM
    customer_address a
JOIN
    customer c ON a.ca_address_sk = c.c_current_addr_sk
JOIN
    store_sales s ON c.c_customer_sk = s.ss_customer_sk
JOIN
    March1998 m ON s.ss_sold_date_sk = m.d_date_sk
JOIN
    item i ON s.ss_item_sk = i.i_item_sk
JOIN
    CategoryAvgPrice cap ON i.i_category = cap.i_category
WHERE
    i.i_current_price > 1.2 * cap.avg_price
GROUP BY
    a.ca_state
HAVING
    COUNT(*) >= 10
ORDER BY
    cnt,
    a.ca_state
LIMIT 100;