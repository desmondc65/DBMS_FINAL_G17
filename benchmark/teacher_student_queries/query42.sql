SELECT
    dt.d_year,
    item.i_category_id,
    item.i_category,
    SUM(ss.ss_ext_sales_price) AS total_sales
FROM
    store_sales ss
JOIN
    date_dim dt ON ss.ss_sold_date_sk = dt.d_date_sk
JOIN
    item ON ss.ss_item_sk = item.i_item_sk
WHERE
    dt.d_year = 1998
    AND dt.d_moy = 11
    AND item.i_manager_id = 1
GROUP BY
    dt.d_year,
    item.i_category_id,
    item.i_category
ORDER BY
    total_sales DESC,
    dt.d_year,
    item.i_category_id,
    item.i_category
LIMIT 100;
