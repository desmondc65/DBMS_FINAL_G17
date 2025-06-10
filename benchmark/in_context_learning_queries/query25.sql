SELECT
  i_item_id,
  i_item_desc,
  s_store_id,
  s_store_name,
  MIN(ss_net_profit) AS store_sales_profit,
  MIN(sr_net_loss) AS store_returns_loss,
  MIN(cs_net_profit) AS catalog_sales_profit
FROM store_sales AS ss
JOIN item AS i
  ON i.i_item_sk = ss.ss_item_sk
JOIN store AS s
  ON s.s_store_sk = ss.ss_store_sk
JOIN date_dim AS d1
  ON d1.d_date_sk = ss.ss_sold_date_sk
JOIN store_returns AS sr
  ON ss.ss_customer_sk = sr.sr_customer_sk
  AND ss.ss_item_sk = sr.sr_item_sk
  AND ss.ss_ticket_number = sr.sr_ticket_number
JOIN date_dim AS d2
  ON sr.sr_returned_date_sk = d2.d_date_sk
JOIN catalog_sales AS cs
  ON sr.sr_customer_sk = cs.cs_bill_customer_sk
  AND sr.sr_item_sk = cs.cs_item_sk
JOIN date_dim AS d3
  ON cs.cs_sold_date_sk = d3.d_date_sk
WHERE
  d1.d_moy = 4
  AND d1.d_year = 2002
  AND d2.d_moy BETWEEN 4 AND 10
  AND d2.d_year = 2002
  AND d3.d_moy BETWEEN 4 AND 10
  AND d3.d_year = 2002
GROUP BY
  i_item_id,
  i_item_desc,
  s_store_id,
  s_store_name
ORDER BY
  i_item_id,
  i_item_desc,
  s_store_id,
  s_store_name
LIMIT 100
