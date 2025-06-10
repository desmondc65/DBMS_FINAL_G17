SELECT
  i_manufact_id,
  SUM(total_sales) AS total_sales
FROM (
  SELECT
    i.i_manufact_id,
    SUM(ss.ss_ext_sales_price) AS total_sales
  FROM store_sales AS ss
  JOIN date_dim AS d
    ON ss.ss_sold_date_sk = d.d_date_sk
  JOIN customer_address AS ca
    ON ss.ss_addr_sk = ca.ca_address_sk
  JOIN item AS i
    ON ss.ss_item_sk = i.i_item_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM item AS i2
      WHERE
        i2.i_manufact_id = i.i_manufact_id AND i2.i_category = 'Books'
    )
    AND d.d_year = 1999
    AND d.d_moy = 4
    AND ca.ca_gmt_offset = -5
  GROUP BY
    i.i_manufact_id
  UNION ALL
  SELECT
    i.i_manufact_id,
    SUM(cs.cs_ext_sales_price) AS total_sales
  FROM catalog_sales AS cs
  JOIN date_dim AS d
    ON cs.cs_sold_date_sk = d.d_date_sk
  JOIN customer_address AS ca
    ON cs.cs_bill_addr_sk = ca.ca_address_sk
  JOIN item AS i
    ON cs.cs_item_sk = i.i_item_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM item AS i2
      WHERE
        i2.i_manufact_id = i.i_manufact_id AND i2.i_category = 'Books'
    )
    AND d.d_year = 1999
    AND d.d_moy = 4
    AND ca.ca_gmt_offset = -5
  GROUP BY
    i.i_manufact_id
  UNION ALL
  SELECT
    i.i_manufact_id,
    SUM(ws.ws_ext_sales_price) AS total_sales
  FROM web_sales AS ws
  JOIN date_dim AS d
    ON ws.ws_sold_date_sk = d.d_date_sk
  JOIN customer_address AS ca
    ON ws.ws_bill_addr_sk = ca.ca_address_sk
  JOIN item AS i
    ON ws.ws_item_sk = i.i_item_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM item AS i2
      WHERE
        i2.i_manufact_id = i.i_manufact_id AND i2.i_category = 'Books'
    )
    AND d.d_year = 1999
    AND d.d_moy = 4
    AND ca.ca_gmt_offset = -5
  GROUP BY
    i.i_manufact_id
) AS tmp1
GROUP BY
  i_manufact_id
ORDER BY
  total_sales
LIMIT 100
