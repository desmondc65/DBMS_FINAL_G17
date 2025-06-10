SELECT sum(sales)
FROM (
    SELECT cs_quantity * cs_list_price AS sales
    FROM catalog_sales cs
    JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk
    WHERE dd.d_year = 2000
      AND dd.d_moy = 3
      AND EXISTS (
        SELECT 1
        FROM frequent_ss_items fsi
        WHERE cs.cs_item_sk = fsi.item_sk
    )
    AND EXISTS (
        SELECT 1
        FROM best_ss_customer bsc
        WHERE cs.cs_bill_customer_sk = bsc.c_customer_sk
    )
    UNION ALL
    SELECT ws_quantity * ws_list_price AS sales
    FROM web_sales ws
    JOIN date_dim dd ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE dd.d_year = 2000
      AND dd.d_moy = 3
      AND EXISTS (
        SELECT 1
        FROM frequent_ss_items fsi
        WHERE ws.ws_item_sk = fsi.item_sk
    )
    AND EXISTS (
        SELECT 1
        FROM best_ss_customer bsc
        WHERE ws.ws_bill_customer_sk = bsc.c_customer_sk
    )
) AS temp2
LIMIT 100;
