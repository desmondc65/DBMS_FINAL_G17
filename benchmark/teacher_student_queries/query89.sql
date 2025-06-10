SELECT *
FROM (
    SELECT
        i_category,
        i_class,
        i_brand,
        s_store_name,
        s_company_name,
        d_moy,
        SUM(ss_sales_price) AS sum_sales,
        AVG(SUM(ss_sales_price)) OVER (PARTITION BY i_category, i_brand, s_store_name, s_company_name) AS avg_monthly_sales
    FROM store_sales ss
    INNER JOIN item i ON ss.ss_item_sk = i.i_item_sk
    INNER JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    INNER JOIN store s ON ss.ss_store_sk = s.s_store_sk
    WHERE d_year = 2001
      AND (
            (i_category IN ('Children', 'Jewelry', 'Home') AND i_class IN ('infants', 'birdal', 'flatware'))
            OR
            (i_category IN ('Electronics', 'Music', 'Books') AND i_class IN ('audio', 'classical', 'science'))
        )
    GROUP BY i_category, i_class, i_brand, s_store_name, s_company_name, d_moy
) AS tmp1
WHERE CASE WHEN (avg_monthly_sales <> 0) THEN (ABS(sum_sales - avg_monthly_sales) / avg_monthly_sales) ELSE NULL END > 0.1
ORDER BY sum_sales - avg_monthly_sales, s_store_name
LIMIT 100;