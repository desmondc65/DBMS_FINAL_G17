WITH AvgDiscount AS (
    SELECT
        1.3 * avg(ws_ext_discount_amt) AS avg_discount
    FROM
        web_sales ws
    JOIN
        date_dim dd ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
        dd.d_date BETWEEN '2001-01-25' AND date_add(cast('2001-01-25' as date), interval 90 day)
)
SELECT
    SUM(ws.ws_ext_discount_amt) AS "Excess Discount Amount"
FROM
    web_sales ws
JOIN
    item i ON i.i_item_sk = ws.ws_item_sk
JOIN
    date_dim dd ON dd.d_date_sk = ws.ws_sold_date_sk
JOIN
    AvgDiscount ad ON 1=1  -- Uncorrelated subquery, so join on a dummy condition
WHERE
    i.i_manufact_id = 914
    AND dd.d_date BETWEEN '2001-01-25' AND date_add(cast('2001-01-25' as date), interval 90 day)
    AND ws.ws_ext_discount_amt > ad.avg_discount
ORDER BY
    SUM(ws.ws_ext_discount_amt)
LIMIT 100;
