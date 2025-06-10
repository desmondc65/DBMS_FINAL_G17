SELECT
    dt.d_year,
    item.i_brand_id AS brand_id,
    item.i_brand AS brand,
    SUM(ss.ss_ext_sales_price) AS ext_price
FROM
    date_dim AS dt
JOIN
    store_sales AS ss ON dt.d_date_sk = ss.ss_sold_date_sk
JOIN
    item AS item ON ss.ss_item_sk = item.i_item_sk
WHERE
    item.i_manager_id = 1
    AND dt.d_moy = 11
    AND dt.d_year = 2000
GROUP BY
    dt.d_year,
    item.i_brand,
    item.i_brand_id
ORDER BY
    dt.d_year,
    ext_price DESC,
    brand_id
LIMIT 100;
