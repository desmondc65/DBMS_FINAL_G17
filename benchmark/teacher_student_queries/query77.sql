WITH DateRange AS (
    SELECT d_date_sk
    FROM date_dim
    WHERE d_date >= CAST('2001-08-11' AS DATE) AND d_date < DATE_ADD(CAST('2001-08-11' AS DATE), INTERVAL 31 DAY)
),
ss AS (
    SELECT s_store_sk,
           SUM(ss_ext_sales_price) AS sales,
           SUM(ss_net_profit) AS profit
    FROM store_sales ss
    JOIN DateRange dr ON ss.ss_sold_date_sk = dr.d_date_sk
    JOIN store s ON ss.ss_store_sk = s.s_store_sk
    GROUP BY s_store_sk
),
sr AS (
    SELECT s_store_sk,
           SUM(sr_return_amt) AS returns,
           SUM(sr_net_loss) AS profit_loss
    FROM store_returns sr
    JOIN DateRange dr ON sr.sr_returned_date_sk = dr.d_date_sk
    JOIN store s ON sr.sr_store_sk = s.s_store_sk
    GROUP BY s_store_sk
),
cs AS (
    SELECT cs_call_center_sk,
           SUM(cs_ext_sales_price) AS sales,
           SUM(cs_net_profit) AS profit
    FROM catalog_sales cs
    JOIN DateRange dr ON cs.cs_sold_date_sk = dr.d_date_sk
    GROUP BY cs_call_center_sk
),
cr AS (
    SELECT cr_call_center_sk,
           SUM(cr_return_amount) AS returns,
           SUM(cr_net_loss) AS profit_loss
    FROM catalog_returns cr
    JOIN DateRange dr ON cr.cr_returned_date_sk = dr.d_date_sk
    GROUP BY cr_call_center_sk
),
ws AS (
    SELECT wp_web_page_sk,
           SUM(ws_ext_sales_price) AS sales,
           SUM(ws_net_profit) AS profit
    FROM web_sales ws
    JOIN DateRange dr ON ws.ws_sold_date_sk = dr.d_date_sk
    JOIN web_page wp ON ws.ws_web_page_sk = wp.wp_web_page_sk
    GROUP BY wp_web_page_sk
),
wr AS (
    SELECT wp_web_page_sk,
           SUM(wr_return_amt) AS returns,
           SUM(wr_net_loss) AS profit_loss
    FROM web_returns wr
    JOIN DateRange dr ON wr.wr_returned_date_sk = dr.d_date_sk
    JOIN web_page wp ON wr.wr_web_page_sk = wp.wp_web_page_sk
    GROUP BY wp_web_page_sk
)
SELECT channel,
       id,
       SUM(sales) AS sales,
       SUM(returns) AS returns,
       SUM(profit) AS profit
FROM (
    SELECT 'store channel' AS channel,
           ss.s_store_sk AS id,
           sales,
           COALESCE(returns, 0) AS returns,
           (profit - COALESCE(profit_loss, 0)) AS profit
    FROM ss
    LEFT JOIN sr ON ss.s_store_sk = sr.s_store_sk
    UNION ALL
    SELECT 'catalog channel' AS channel,
           cs_call_center_sk AS id,
           sales,
           returns,
           (profit - profit_loss) AS profit
    FROM cs, cr
    UNION ALL
    SELECT 'web channel' AS channel,
           ws.wp_web_page_sk AS id,
           sales,
           COALESCE(returns, 0) returns,
           (profit - COALESCE(profit_loss, 0)) AS profit
    FROM ws
    LEFT JOIN wr ON ws.wp_web_page_sk = wr.wp_web_page_sk
) x
GROUP BY channel, id WITH ROLLUP
ORDER BY channel, id
LIMIT 100;
