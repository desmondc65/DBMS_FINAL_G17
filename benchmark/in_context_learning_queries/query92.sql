SELECT
  sum(ws_ext_discount_amt) AS "Excess Discount Amount"
FROM web_sales AS ws
JOIN item AS i
  ON i.i_item_sk = ws.ws_item_sk
JOIN date_dim AS d
  ON d.d_date_sk = ws.ws_sold_date_sk
WHERE
  i.i_manufact_id = 914
  AND d.d_date BETWEEN '2001-01-25' AND DATE_ADD(CAST('2001-01-25' AS DATE), INTERVAL 90 DAY)
  AND ws.ws_ext_discount_amt > (
    SELECT
      1.3 * avg(ws2.ws_ext_discount_amt)
    FROM web_sales AS ws2
    JOIN date_dim AS d2
      ON d2.d_date_sk = ws2.ws_sold_date_sk
    WHERE
      ws2.ws_item_sk = i.i_item_sk
      AND d2.d_date BETWEEN '2001-01-25' AND DATE_ADD(CAST('2001-01-25' AS DATE), INTERVAL 90 DAY)
  )
ORDER BY
  sum(ws_ext_discount_amt)
LIMIT 100
;
