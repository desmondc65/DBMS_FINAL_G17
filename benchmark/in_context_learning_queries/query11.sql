WITH YearTotals AS (
  SELECT
    c_customer_id AS customer_id,
    c_first_name AS customer_first_name,
    c_last_name AS customer_last_name,
    c_email_address AS customer_email_address,
    d_year AS dyear,
    SUM(ss_ext_list_price - ss_ext_discount_amt) AS year_total,
    's' AS sale_type
  FROM customer AS c
  JOIN store_sales AS ss
    ON c.c_customer_sk = ss.ss_customer_sk
  JOIN date_dim AS dd
    ON ss.ss_sold_date_sk = dd.d_date_sk
  GROUP BY
    c_customer_id,
    c_first_name,
    c_last_name,
    c_email_address,
    d_year
  UNION ALL
  SELECT
    c_customer_id AS customer_id,
    c_first_name AS customer_first_name,
    c_last_name AS customer_last_name,
    c_email_address AS customer_email_address,
    d_year AS dyear,
    SUM(ws_ext_list_price - ws_ext_discount_amt) AS year_total,
    'w' AS sale_type
  FROM customer AS c
  JOIN web_sales AS ws
    ON c.c_customer_sk = ws.ws_bill_customer_sk
  JOIN date_dim AS dd
    ON ws.ws_sold_date_sk = dd.d_date_sk
  GROUP BY
    c_customer_id,
    c_first_name,
    c_last_name,
    c_email_address,
    d_year
)
SELECT
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name,
  t_s_secyear.customer_email_address
FROM YearTotals AS t_s_firstyear
JOIN YearTotals AS t_s_secyear
  ON t_s_secyear.customer_id = t_s_firstyear.customer_id
JOIN YearTotals AS t_w_firstyear
  ON t_s_firstyear.customer_id = t_w_firstyear.customer_id
JOIN YearTotals AS t_w_secyear
  ON t_s_firstyear.customer_id = t_w_secyear.customer_id
WHERE t_s_firstyear.sale_type = 's'
AND t_w_firstyear.sale_type = 'w'
AND t_s_secyear.sale_type = 's'
AND t_w_secyear.sale_type = 'w'
AND t_s_firstyear.dyear = 1999
AND t_s_secyear.dyear = 2000
AND t_w_firstyear.dyear = 1999
AND t_w_secyear.dyear = 2000
AND t_s_firstyear.year_total > 0
AND t_w_firstyear.year_total > 0
AND CASE
  WHEN t_w_firstyear.year_total > 0
  THEN t_w_secyear.year_total / t_w_firstyear.year_total
  ELSE 0.0
END > CASE
  WHEN t_s_firstyear.year_total > 0
  THEN t_s_secyear.year_total / t_s_firstyear.year_total
  ELSE 0.0
END
ORDER BY
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name,
  t_s_secyear.customer_email_address
LIMIT 100
