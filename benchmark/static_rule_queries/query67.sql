SELECT
  *
FROM (
  SELECT
    i_category,
    i_class,
    i_brand,
    i_product_name,
    d_year,
    d_qoy,
    d_moy,
    s_store_id,
    sumsales,
    RANK() OVER (PARTITION BY i_category ORDER BY sumsales DESC) AS rk
  FROM (
    SELECT
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      s_store_id,
      SUM(COALESCE(ss_sales_price * ss_quantity, 0)) AS sumsales
    FROM store_sales AS ss
    JOIN date_dim AS dd
      ON ss.ss_sold_date_sk = dd.d_date_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    JOIN item AS i
      ON ss.ss_item_sk = i.i_item_sk
    WHERE
      dd.d_month_seq BETWEEN 1194 AND 1205
    GROUP BY
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      s_store_id
    WITH ROLLUP
  ) AS dw1
) AS dw2
WHERE
  rk <= 100
ORDER BY
  i_category,
  i_class,
  i_brand,
  i_product_name,
  d_year,
  d_qoy,
  d_moy,
  s_store_id,
  sumsales,
  rk
LIMIT 100
