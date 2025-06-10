WITH ClassRevenue AS (
    SELECT
        i.i_class,
        SUM(ws.ws_ext_sales_price) AS class_revenue
    FROM
        web_sales ws
    INNER JOIN
        item i ON ws.ws_item_sk = i.i_item_sk
    INNER JOIN
        date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
    WHERE
        i.i_category IN ('Jewelry', 'Books', 'Women')
        AND d.d_date BETWEEN DATE('2002-03-22') AND DATE('2002-04-21')
    GROUP BY
        i.i_class
)
SELECT
    i.i_item_id,
    i.i_item_desc,
    i.i_category,
    i.i_class,
    i.i_current_price,
    SUM(ws.ws_ext_sales_price) AS itemrevenue,
    SUM(ws.ws_ext_sales_price) * 100 / cr.class_revenue AS revenueratio
FROM
    web_sales ws
INNER JOIN
    item i ON ws.ws_item_sk = i.i_item_sk
INNER JOIN
    date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
INNER JOIN
    ClassRevenue cr ON i.i_class = cr.i_class
WHERE
    i.i_category IN ('Jewelry', 'Books', 'Women')
    AND d.d_date BETWEEN DATE('2002-03-22') AND DATE('2002-04-21')
GROUP BY
    i.i_item_id,
    i.i_item_desc,
    i.i_category,
    i.i_class,
    i.i_current_price,
    cr.class_revenue
ORDER BY
    i.i_category,
    i.i_class,
    i.i_item_id,
    i.i_item_desc,
    revenueratio
LIMIT 100;