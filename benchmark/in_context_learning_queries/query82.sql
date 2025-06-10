SELECT i_item_id, i_item_desc, i_current_price
FROM item
WHERE i_current_price BETWEEN 69 AND 99
AND i_manufact_id IN (105, 513, 180, 137)
AND EXISTS (
    SELECT 1
    FROM inventory
    JOIN date_dim ON d_date_sk = inv_date_sk
    WHERE inv_item_sk = i_item_sk
    AND d_date BETWEEN '1998-06-06' AND DATE_ADD('1998-06-06', INTERVAL 60 DAY)
    AND inv_quantity_on_hand BETWEEN 100 AND 500
    AND EXISTS (
        SELECT 1
        FROM store_sales
        WHERE ss_item_sk = i_item_sk
    )
)
GROUP BY i_item_id, i_item_desc, i_current_price
ORDER BY i_item_id
LIMIT 100;
