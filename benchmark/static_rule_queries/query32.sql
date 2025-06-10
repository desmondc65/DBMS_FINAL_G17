SELECT
  SUM(cs_ext_discount_amt) AS "excess discount amount"
FROM catalog_sales AS cs
JOIN item AS i
  ON i.i_item_sk = cs.cs_item_sk
JOIN date_dim AS d
  ON d.d_date_sk = cs.cs_sold_date_sk
WHERE
  i.i_manufact_id = 283
  AND d.d_date BETWEEN '1999-02-22' AND DATE_ADD(CAST('1999-02-22' AS DATE), INTERVAL 90 DAY)
  AND cs_ext_discount_amt > (
    SELECT
      1.3 * AVG(cs2.cs_ext_discount_amt)
    FROM catalog_sales AS cs2
    JOIN date_dim AS d2
      ON d2.d_date_sk = cs2.cs_sold_date_sk
    WHERE
      cs2.cs_item_sk = i.i_item_sk
      AND d2.d_date BETWEEN '1999-02-22' AND DATE_ADD(CAST('1999-02-22' AS DATE), INTERVAL 90 DAY)
  )
LIMIT 100
;
