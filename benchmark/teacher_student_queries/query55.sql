SELECT
    i_brand_id brand_id,
    i_brand brand,
    SUM(ss_ext_sales_price) ext_price
FROM
    date_dim
INNER JOIN store_sales ON d_date_sk = ss_sold_date_sk
INNER JOIN item ON ss_item_sk = i_item_sk
WHERE
    i_manager_id = 20
    AND d_moy = 12
    AND d_year = 1998
GROUP BY
    i_brand,
    i_brand_id
ORDER BY
    ext_price DESC,
    i_brand_id
LIMIT 100;
