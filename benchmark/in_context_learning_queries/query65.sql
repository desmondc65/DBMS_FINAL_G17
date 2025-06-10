SELECT 
    s_store_name,
    i_item_desc,
    sc.revenue,
    i_current_price,
    i_wholesale_cost,
    i_brand
FROM store AS s
JOIN (
    SELECT ss_store_sk, ss_item_sk, SUM(ss_sales_price) AS revenue
    FROM store_sales AS ss
    JOIN date_dim AS dd ON ss.ss_sold_date_sk = dd.d_date_sk
    WHERE dd.d_month_seq BETWEEN 1186 AND 1197
    GROUP BY ss_store_sk, ss_item_sk
) AS sc ON s.s_store_sk = sc.ss_store_sk
JOIN item AS i ON i_item_sk = sc.ss_item_sk
JOIN (
    SELECT ss_store_sk, AVG(revenue) AS ave
    FROM (
        SELECT ss_store_sk, ss_item_sk, SUM(ss_sales_price) AS revenue
        FROM store_sales AS ss
        JOIN date_dim AS dd ON ss.ss_sold_date_sk = dd.d_date_sk
        WHERE dd.d_month_seq BETWEEN 1186 AND 1197
        GROUP BY ss_store_sk, ss_item_sk
    ) AS sa
    GROUP BY ss_store_sk
) AS sb ON sc.ss_store_sk = sb.ss_store_sk
WHERE sc.revenue <= 0.1 * sb.ave
ORDER BY s_store_name, i_item_desc
LIMIT 100;
