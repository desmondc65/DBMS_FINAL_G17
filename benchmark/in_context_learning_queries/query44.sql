SELECT
  asceding.rnk,
  i1.i_product_name,
  i2.i_product_name
FROM (
  SELECT
    item_sk,
    RANK() OVER (ORDER BY AVG(ss_net_profit) ASC) AS rnk
  FROM store_sales
  WHERE
    ss_store_sk = 6
  GROUP BY
    ss_item_sk
  HAVING
    AVG(ss_net_profit) > (
      SELECT
        0.9 * AVG(ss_net_profit)
      FROM store_sales
      WHERE
        ss_store_sk = 6
        AND ss_hdemo_sk IS NULL
    )
) AS asceding
JOIN (
  SELECT
    item_sk,
    RANK() OVER (ORDER BY AVG(ss_net_profit) DESC) AS rnk
  FROM store_sales
  WHERE
    ss_store_sk = 6
  GROUP BY
    ss_item_sk
  HAVING
    AVG(ss_net_profit) > (
      SELECT
        0.9 * AVG(ss_net_profit)
      FROM store_sales
      WHERE
        ss_store_sk = 6
        AND ss_hdemo_sk IS NULL
    )
) AS descending
  ON asceding.rnk = descending.rnk
JOIN item AS i1
  ON i1.i_item_sk = asceding.item_sk
JOIN item AS i2
  ON i2.i_item_sk = descending.item_sk
WHERE
  asceding.rnk < 11
  AND descending.rnk < 11
ORDER BY
  asceding.rnk
LIMIT 100
