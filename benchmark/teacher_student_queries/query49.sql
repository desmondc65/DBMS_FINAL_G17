WITH WebData AS (
    SELECT
        ws.ws_item_sk AS item,
        SUM(COALESCE(wr.wr_return_quantity, 0)) AS web_return_quantity,
        SUM(COALESCE(ws.ws_quantity, 0)) AS web_quantity,
        SUM(COALESCE(wr.wr_return_amt, 0)) AS web_return_amt,
        SUM(COALESCE(ws.ws_net_paid, 0)) AS web_net_paid
    FROM
        web_sales ws
    LEFT OUTER JOIN
        web_returns wr ON ws.ws_order_number = wr.wr_order_number AND ws.ws_item_sk = wr.wr_item_sk
    JOIN
        date_dim dd ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
        wr.wr_return_amt > 10000
        AND ws.ws_net_profit > 1
        AND ws.ws_net_paid > 0
        AND ws.ws_quantity > 0
        AND dd.d_year = 2000
        AND dd.d_moy = 12
    GROUP BY
        ws.ws_item_sk
),
CatalogData AS (
    SELECT
        cs.cs_item_sk AS item,
        SUM(COALESCE(cr.cr_return_quantity, 0)) AS catalog_return_quantity,
        SUM(COALESCE(cs.cs_quantity, 0)) AS catalog_quantity,
        SUM(COALESCE(cr.cr_return_amount, 0)) AS catalog_return_amt,
        SUM(COALESCE(cs.cs_net_paid, 0)) AS catalog_net_paid
    FROM
        catalog_sales cs
    LEFT OUTER JOIN
        catalog_returns cr ON cs.cs_order_number = cr.cr_order_number AND cs.cs_item_sk = cr.cr_item_sk
    JOIN
        date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk
    WHERE
        cr.cr_return_amount > 10000
        AND cs.cs_net_profit > 1
        AND cs.cs_net_paid > 0
        AND cs.cs_quantity > 0
        AND dd.d_year = 2000
        AND dd.d_moy = 12
    GROUP BY
        cs.cs_item_sk
),
StoreData AS (
    SELECT
        sts.ss_item_sk AS item,
        SUM(COALESCE(sr.sr_return_quantity, 0)) AS store_return_quantity,
        SUM(COALESCE(sts.ss_quantity, 0)) AS store_quantity,
        SUM(COALESCE(sr.sr_return_amt, 0)) AS store_return_amt,
        SUM(COALESCE(sts.ss_net_paid, 0)) AS store_net_paid
    FROM
        store_sales sts
    LEFT OUTER JOIN
        store_returns sr ON sts.ss_ticket_number = sr.sr_ticket_number AND sts.ss_item_sk = sr.sr_item_sk
    JOIN
        date_dim dd ON sts.ss_sold_date_sk = dd.d_date_sk
    WHERE
        sr.sr_return_amt > 10000
        AND sts.ss_net_profit > 1
        AND sts.ss_net_paid > 0
        AND sts.ss_quantity > 0
        AND dd.d_year = 2000
        AND dd.d_moy = 12
    GROUP BY
        sts.ss_item_sk
),
WebRanks AS (
    SELECT
        'web' AS channel,
        item,
        (CAST(web_return_quantity AS DECIMAL(15, 4)) / CAST(web_quantity AS DECIMAL(15, 4))) AS return_ratio,
        (CAST(web_return_amt AS DECIMAL(15, 4)) / CAST(web_net_paid AS DECIMAL(15, 4))) AS currency_ratio,
        RANK() OVER (ORDER BY (CAST(web_return_quantity AS DECIMAL(15, 4)) / CAST(web_quantity AS DECIMAL(15, 4)))) AS return_rank,
        RANK() OVER (ORDER BY (CAST(web_return_amt AS DECIMAL(15, 4)) / CAST(web_net_paid AS DECIMAL(15, 4)))) AS currency_rank
    FROM
        WebData
),
CatalogRanks AS (
    SELECT
        'catalog' AS channel,
        item,
        (CAST(catalog_return_quantity AS DECIMAL(15, 4)) / CAST(catalog_quantity AS DECIMAL(15, 4))) AS return_ratio,
        (CAST(catalog_return_amt AS DECIMAL(15, 4)) / CAST(catalog_net_paid AS DECIMAL(15, 4))) AS currency_ratio,
        RANK() OVER (ORDER BY (CAST(catalog_return_quantity AS DECIMAL(15, 4)) / CAST(catalog_quantity AS DECIMAL(15, 4)))) AS return_rank,
        RANK() OVER (ORDER BY (CAST(catalog_return_amt AS DECIMAL(15, 4)) / CAST(catalog_net_paid AS DECIMAL(15, 4)))) AS currency_rank
    FROM
        CatalogData
),
StoreRanks AS (
    SELECT
        'store' AS channel,
        item,
        (CAST(store_return_quantity AS DECIMAL(15, 4)) / CAST(store_quantity AS DECIMAL(15, 4))) AS return_ratio,
        (CAST(store_return_amt AS DECIMAL(15, 4)) / CAST(store_net_paid AS DECIMAL(15, 4))) AS currency_ratio,
        RANK() OVER (ORDER BY (CAST(store_return_quantity AS DECIMAL(15, 4)) / CAST(store_quantity AS DECIMAL(15, 4)))) AS return_rank,
        RANK() OVER (ORDER BY (CAST(store_return_amt AS DECIMAL(15, 4)) / CAST(store_net_paid AS DECIMAL(15, 4)))) AS currency_rank
    FROM
        StoreData
)
SELECT channel, item, return_ratio, return_rank, currency_rank
FROM WebRanks
WHERE return_rank <= 10 OR currency_rank <= 10
UNION ALL
SELECT channel, item, return_ratio, return_rank, currency_rank
FROM CatalogRanks
WHERE return_rank <= 10 OR currency_rank <= 10
UNION ALL
SELECT channel, item, return_ratio, return_rank, currency_rank
FROM StoreRanks
WHERE return_rank <= 10 OR currency_rank <= 10
ORDER BY 1, 4, 5, 2
LIMIT 100;
