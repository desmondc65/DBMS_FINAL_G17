SELECT
  tmp1.*
FROM (
  SELECT
    i.i_category,
    i.i_class,
    i.i_brand,
    s.s_store_name,
    s.s_company_name,
    d.d_moy,
    SUM(ss.ss_sales_price) AS sum_sales,
    AVG(SUM(ss.ss_sales_price)) OVER (PARTITION BY i.i_category, i.i_brand, s.s_store_name, s.s_company_name) AS avg_monthly_sales
  FROM store_sales AS ss
  JOIN item AS i
    ON ss.ss_item_sk = i.i_item_sk
  JOIN date_dim AS d
    ON ss.ss_sold_date_sk = d.d_date_sk
  JOIN store AS s
    ON ss.ss_store_sk = s.s_store_sk
  WHERE
    d.d_year = 2001
    AND (i.i_category IN ('Children', 'Jewelry', 'Home') AND i.i_class IN ('infants', 'birdal', 'flatware') OR i.i_category IN ('Electronics', 'Music', 'Books') AND i.i_class IN ('audio', 'classical', 'science'))
  GROUP BY
    i.i_category,
    i.i_class,
    i.i_brand,
    s.s_store_name,
    s.s_company_name,
    d.d_moy
) AS tmp1
WHERE
  CASE
    WHEN (
      tmp1.avg_monthly_sales <> 0
    )
    THEN (
      ABS(tmp1.sum_sales - tmp1.avg_monthly_sales) / tmp1.avg_monthly_sales
    )
    ELSE NULL
  END > 0.1
ORDER BY
  tmp1.sum_sales - tmp1.avg_monthly_sales,
  tmp1.s_store_name
LIMIT 100
