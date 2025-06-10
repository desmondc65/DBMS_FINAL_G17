SELECT
  i_item_id,
  i_item_desc,
  s_state,
  COUNT(ss_quantity) AS store_sales_quantitycount,
  AVG(ss_quantity) AS store_sales_quantityave,
  STDDEV_SAMP(ss_quantity) AS store_sales_quantitystdev,
  STDDEV_SAMP(ss_quantity) / AVG(ss_quantity) AS store_sales_quantitycov,
  COUNT(sr_return_quantity) AS store_returns_quantitycount,
  AVG(sr_return_quantity) AS store_returns_quantityave,
  STDDEV_SAMP(sr_return_quantity) AS store_returns_quantitystdev,
  STDDEV_SAMP(sr_return_quantity) / AVG(sr_return_quantity) AS store_returns_quantitycov,
  COUNT(cs_quantity) AS catalog_sales_quantitycount,
  AVG(cs_quantity) AS catalog_sales_quantityave,
  STDDEV_SAMP(cs_quantity) AS catalog_sales_quantitystdev,
  STDDEV_SAMP(cs_quantity) / AVG(cs_quantity) AS catalog_sales_quantitycov
FROM store_sales AS ss
INNER JOIN item AS i
  ON ss.ss_item_sk = i.i_item_sk
INNER JOIN store AS s
  ON ss.ss_store_sk = s.s_store_sk
INNER JOIN date_dim AS d1
  ON ss.ss_sold_date_sk = d1.d_date_sk
INNER JOIN store_returns AS sr
  ON ss.ss_customer_sk = sr.sr_customer_sk
  AND ss.ss_item_sk = sr.sr_item_sk
  AND ss.ss_ticket_number = sr.sr_ticket_number
INNER JOIN date_dim AS d2
  ON sr.sr_returned_date_sk = d2.d_date_sk
INNER JOIN catalog_sales AS cs
  ON sr.sr_customer_sk = cs.cs_bill_customer_sk
  AND sr.sr_item_sk = cs.cs_item_sk
INNER JOIN date_dim AS d3
  ON cs.cs_sold_date_sk = d3.d_date_sk
WHERE
  d1.d_quarter_name = '1999Q1'
  AND d2.d_quarter_name IN ('1999Q1', '1999Q2', '1999Q3')
  AND d3.d_quarter_name IN ('1999Q1', '1999Q2', '1999Q3')
GROUP BY
  i_item_id,
  i_item_desc,
  s_state
ORDER BY
  i_item_id,
  i_item_desc,
  s_state
LIMIT 100
