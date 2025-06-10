SELECT
  s_store_name,
  s_company_id,
  s_street_number,
  s_street_name,
  s_street_type,
  s_suite_number,
  s_city,
  s_county,
  s_state,
  s_zip,
  SUM(CASE WHEN (sr.sr_returned_date_sk - ss.ss_sold_date_sk <= 30) THEN 1 ELSE 0 END) AS "30 days",
  SUM(CASE WHEN (sr.sr_returned_date_sk - ss.ss_sold_date_sk > 30) AND (sr.sr_returned_date_sk - ss.ss_sold_date_sk <= 60) THEN 1 ELSE 0 END) AS "31-60 days",
  SUM(CASE WHEN (sr.sr_returned_date_sk - ss.ss_sold_date_sk > 60) AND (sr.sr_returned_date_sk - ss.ss_sold_date_sk <= 90) THEN 1 ELSE 0 END) AS "61-90 days",
  SUM(CASE WHEN (sr.sr_returned_date_sk - ss.ss_sold_date_sk > 90) AND (sr.sr_returned_date_sk - ss.ss_sold_date_sk <= 120) THEN 1 ELSE 0 END) AS "91-120 days",
  SUM(CASE WHEN (sr.sr_returned_date_sk - ss.ss_sold_date_sk > 120) THEN 1 ELSE 0 END) AS ">120 days"
FROM store_sales AS ss
JOIN store_returns AS sr
  ON ss.ss_ticket_number = sr.sr_ticket_number AND ss.ss_item_sk = sr.sr_item_sk AND ss.ss_customer_sk = sr.sr_customer_sk
JOIN store AS s
  ON ss.ss_store_sk = s.s_store_sk
JOIN date_dim AS d1
  ON ss.ss_sold_date_sk = d1.d_date_sk
JOIN date_dim AS d2
  ON sr.sr_returned_date_sk = d2.d_date_sk
WHERE
  d2.d_year = 2002 AND d2.d_moy = 8
GROUP BY
  s_store_name,
  s_company_id,
  s_street_number,
  s_street_name,
  s_street_type,
  s_suite_number,
  s_city,
  s_county,
  s_state,
  s_zip
ORDER BY
  s_store_name,
  s_company_id,
  s_street_number,
  s_street_name,
  s_street_type,
  s_suite_number,
  s_city,
  s_county,
  s_state,
  s_zip
LIMIT 100
