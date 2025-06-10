SELECT i_product_name, i_brand, i_class, i_category, avg(inv_quantity_on_hand) AS qoh
FROM inventory AS inv
JOIN date_dim AS dd ON inv.inv_date_sk = dd.d_date_sk
JOIN item AS i ON inv.inv_item_sk = i.i_item_sk
WHERE dd.d_month_seq BETWEEN 1201 AND 1212
GROUP BY i_product_name, i_brand, i_class, i_category WITH ROLLUP
ORDER BY qoh, i_product_name, i_brand, i_class, i_category
LIMIT 100;
