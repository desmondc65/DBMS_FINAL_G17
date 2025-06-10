WITH store_year_total AS (
    SELECT
        c_customer_id AS customer_id,
        c_first_name AS customer_first_name,
        c_last_name AS customer_last_name,
        c_email_address AS customer_email_address,
        d_year AS dyear,
        SUM(ss_ext_list_price - ss_ext_discount_amt) AS year_total
    FROM customer
    JOIN store_sales ON c_customer_sk = ss_customer_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE d_year IN (1999, 2000)
    GROUP BY
        c_customer_id,
        c_first_name,
        c_last_name,
        c_email_address,
        d_year
),
web_year_total AS (
    SELECT
        c_customer_id AS customer_id,
        c_first_name AS customer_first_name,
        c_last_name AS customer_last_name,
        c_email_address AS customer_email_address,
        d_year AS dyear,
        SUM(ws_ext_list_price - ws_ext_discount_amt) AS year_total
    FROM customer
    JOIN web_sales ON c_customer_sk = ws_bill_customer_sk
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE d_year IN (1999, 2000)
    GROUP BY
        c_customer_id,
        c_first_name,
        c_last_name,
        c_email_address,
        d_year
)
SELECT
    s2.customer_id,
    s2.customer_first_name,
    s2.customer_last_name,
    s2.customer_email_address
FROM store_year_total s1
JOIN store_year_total s2 ON s1.customer_id = s2.customer_id AND s2.dyear = 2000 AND s1.dyear = 1999
JOIN web_year_total w1 ON s1.customer_id = w1.customer_id AND w1.dyear = 1999
JOIN web_year_total w2 ON s1.customer_id = w2.customer_id AND w2.dyear = 2000
WHERE s1.year_total > 0
  AND w1.year_total > 0
  AND CASE
        WHEN w1.year_total > 0 THEN w2.year_total / w1.year_total
        ELSE 0.0
    END > CASE
        WHEN s1.year_total > 0 THEN s2.year_total / s1.year_total
        ELSE 0.0
    END
ORDER BY
    s2.customer_id,
    s2.customer_first_name,
    s2.customer_last_name,
    s2.customer_email_address
LIMIT 100;
