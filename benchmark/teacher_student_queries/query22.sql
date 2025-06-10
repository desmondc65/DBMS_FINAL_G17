SELECT
    i_product_name,
    i_brand,
    i_class,
    i_category,
    AVG(inv_quantity_on_hand) AS qoh
FROM
    inventory inv
JOIN
    item i ON inv.inv_item_sk = i.i_item_sk
JOIN
    (SELECT d_date_sk FROM date_dim WHERE d_month_seq BETWEEN 1201 AND 1212) AS dd
    ON inv.inv_date_sk = dd.d_date_sk
GROUP BY
    i_product_name,
    i_brand,
    i_class,
    i_category WITH ROLLUP
ORDER BY
    qoh,
    i_product_name,
    i_brand,
    i_class,
    i_category
LIMIT 100;
