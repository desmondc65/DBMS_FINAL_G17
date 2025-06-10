SELECT
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name
FROM (
  SELECT
    c.c_customer_id AS customer_id,
    c.c_first_name AS customer_first_name,
    c.c_last_name AS customer_last_name,
    d.d_year AS YEAR,
    STDDEV_SAMP(ss.ss_net_paid) AS year_total
  FROM customer AS c
  JOIN store_sales AS ss
    ON c.c_customer_sk = ss.ss_customer_sk
  JOIN date_dim AS d
    ON ss.ss_sold_date_sk = d.d_date_sk
  WHERE
    d.d_year IN (2001, 2002)
  GROUP BY
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    d.d_year
) AS year_total_s_firstyear
JOIN (
  SELECT
    c.c_customer_id AS customer_id,
    c.c_first_name AS customer_first_name,
    c.c_last_name AS customer_last_name,
    d.d_year AS YEAR,
    STDDEV_SAMP(ws.ws_net_paid) AS year_total
  FROM customer AS c
  JOIN web_sales AS ws
    ON c.c_customer_sk = ws.ws_bill_customer_sk
  JOIN date_dim AS d
    ON ws.ws_sold_date_sk = d.d_date_sk
  WHERE
    d.d_year IN (2001, 2002)
  GROUP BY
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    d.d_year
) AS year_total_w_firstyear
  ON year_total_s_firstyear.customer_id = year_total_w_firstyear.customer_id
JOIN (
  SELECT
    c.c_customer_id AS customer_id,
    c.c_first_name AS customer_first_name,
    c.c_last_name AS customer_last_name,
    d.d_year AS YEAR,
    STDDEV_SAMP(ss.ss_net_paid) AS year_total
  FROM customer AS c
  JOIN store_sales AS ss
    ON c.c_customer_sk = ss.ss_customer_sk
  JOIN date_dim AS d
    ON ss.ss_sold_date_sk = d.d_date_sk
  WHERE
    d.d_year IN (2001, 2002)
  GROUP BY
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    d.d_year
) AS t_s_secyear
  ON year_total_s_firstyear.customer_id = t_s_secyear.customer_id
JOIN (
  SELECT
    c.c_customer_id AS customer_id,
    c.c_first_name AS customer_first_name,
    c.c_last_name AS customer_last_name,
    d.d_year AS YEAR,
    STDDEV_SAMP(ws.ws_net_paid) AS year_total
  FROM customer AS c
  JOIN web_sales AS ws
    ON c.c_customer_sk = ws.ws_bill_customer_sk
  JOIN date_dim AS d
    ON ws.ws_sold_date_sk = d.d_date_sk
  WHERE
    d.d_year IN (2001, 2002)
  GROUP BY
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    d.d_year
) AS t_w_secyear
  ON year_total_s_firstyear.customer_id = t_w_secyear.customer_id
WHERE
  year_total_s_firstyear.YEAR = 2001
  AND year_total_w_firstyear.YEAR = 2001
  AND t_s_secyear.YEAR = 2002
  AND t_w_secyear.YEAR = 2002
  AND year_total_s_firstyear.year_total > 0
  AND year_total_w_firstyear.year_total > 0
  AND CASE
    WHEN year_total_w_firstyear.year_total > 0
    THEN t_w_secyear.year_total / year_total_w_firstyear.year_total
    ELSE NULL
  END > CASE
    WHEN year_total_s_firstyear.year_total > 0
    THEN t_s_secyear.year_total / year_total_s_firstyear.year_total
    ELSE NULL
  END
ORDER BY
  3,
  2,
  1
LIMIT 100
