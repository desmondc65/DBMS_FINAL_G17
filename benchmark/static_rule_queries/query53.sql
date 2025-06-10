SELECT
  tmp1.*
FROM (
  SELECT
    i_manufact_id,
    SUM(ss_sales_price) AS sum_sales,
    AVG(SUM(ss_sales_price)) OVER (PARTITION BY i_manufact_id) AS avg_quarterly_sales
  FROM item AS i
  JOIN store_sales AS ss
    ON ss.ss_item_sk = i.i_item_sk
  JOIN date_dim AS d
    ON ss.ss_sold_date_sk = d.d_date_sk
  JOIN store AS s
    ON ss.ss_store_sk = s.s_store_sk
  WHERE
    d.d_month_seq BETWEEN 1197 AND 1197 + 11
    AND (
      (
        i.i_category IN ('Books', 'Children', 'Electronics')
        AND i.i_class IN ('personal', 'portable', 'reference', 'self-help')
        AND i.i_brand IN ('scholaramalgamalg #14', 'scholaramalgamalg #7', 'exportiunivamalg #9', 'scholaramalgamalg #9')
      )
      OR (
        i.i_category IN ('Women', 'Music', 'Men')
        AND i.i_class IN ('accessories', 'classical', 'fragrances', 'pants')
        AND i.i_brand IN ('amalgimporto #1', 'edu packscholar #1', 'exportiimporto #1', 'importoamalg #1')
      )
    )
  GROUP BY
    i_manufact_id,
    d_qoy
) AS tmp1
WHERE
  CASE
    WHEN avg_quarterly_sales > 0
    THEN ABS(sum_sales - avg_quarterly_sales) / avg_quarterly_sales
    ELSE NULL
  END > 0.1
ORDER BY
  avg_quarterly_sales,
  sum_sales,
  i_manufact_id
LIMIT 100
