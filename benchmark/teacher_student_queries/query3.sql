SELECT
    dt.d_year,
    item.i_brand_id AS brand_id,
    item.i_brand AS brand,
    SUM(ss_net_profit) AS sum_agg
FROM
    store_sales AS ss
INNER JOIN
    date_dim AS dt ON ss.ss_sold_date_sk = dt.d_date_sk
INNER JOIN
    item ON ss.ss_item_sk = item.i_item_sk
WHERE
    item.i_manufact_id = 445
    AND dt.d_moy = 12
GROUP BY
    dt.d_year,
    item.i_brand,
    item.i_brand_id
ORDER BY
    dt.d_year,
    sum_agg DESC,
    brand_id
LIMIT 100;
