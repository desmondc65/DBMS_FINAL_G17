WITH base_sales AS (
    SELECT
        ss_ext_sales_price,
        ss_promo_sk
    FROM
        store_sales ss
    JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN store s ON ss.ss_store_sk = s.s_store_sk
    JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk
    JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
    JOIN item i ON ss.ss_item_sk = i.i_item_sk
    WHERE
        d.d_year = 2002
        AND d.d_moy = 11
        AND s.s_gmt_offset = -6
        AND ca.ca_gmt_offset = -6
        AND i.i_category = 'Sports'
)
SELECT
    promotions,
    total,
    CAST(promotions AS DECIMAL(15, 4)) / CAST(total AS DECIMAL(15, 4)) * 100
FROM
    (
        SELECT
            SUM(ss_ext_sales_price) AS promotions
        FROM
            base_sales bs
        JOIN promotion p ON bs.ss_promo_sk = p.p_promo_sk
        WHERE
            p.p_channel_dmail = 'Y'
            OR p.p_channel_email = 'Y'
            OR p.p_channel_tv = 'Y'
    ) promotional_sales,
    (
        SELECT
            SUM(ss_ext_sales_price) AS total
        FROM
            base_sales
    ) all_sales
ORDER BY
    promotions,
    total
LIMIT 100;
