SELECT i_item_id, i_item_desc, i_current_price
FROM item
JOIN inventory ON inv_item_sk = i_item_sk
JOIN date_dim ON d_date_sk = inv_date_sk
WHERE i_current_price BETWEEN 26 AND 56
AND d_date BETWEEN '2001-06-09' AND date_add('2001-06-09', interval 60 day)
AND i_manufact_id IN (744, 884, 722, 693)
AND inv_quantity_on_hand BETWEEN 100 AND 500
AND EXISTS (
    SELECT 1
    FROM catalog_sales
    WHERE cs_item_sk = i_item_sk
)
GROUP BY i_item_id, i_item_desc, i_current_price
ORDER BY i_item_id
LIMIT 100;
