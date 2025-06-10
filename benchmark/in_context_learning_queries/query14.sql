WITH cross_items AS (
  SELECT
    i_item_sk AS ss_item_sk
  FROM item AS i
  JOIN (
    SELECT DISTINCT
      iss.i_brand_id AS brand_id,
      iss.i_class_id AS class_id,
      iss.i_category_id AS category_id
    FROM store_sales AS ss
    JOIN item AS iss
      ON ss.ss_item_sk = iss.i_item_sk
    JOIN date_dim AS d1
      ON ss.ss_sold_date_sk = d1.d_date_sk
    WHERE
      d1.d_year BETWEEN 1999 AND 2001
      AND EXISTS(
        SELECT
          1
        FROM catalog_sales AS cs
        JOIN item AS ics
          ON cs.cs_item_sk = ics.i_item_sk
        JOIN date_dim AS d2
          ON cs.cs_sold_date_sk = d2.d_date_sk
        WHERE
          d2.d_year BETWEEN 1999 AND 2001
          AND ics.i_brand_id = iss.i_brand_id
          AND ics.i_class_id = iss.i_class_id
          AND ics.i_category_id = iss.i_category_id
      )
      AND EXISTS(
        SELECT
          1
        FROM web_sales AS ws
        JOIN item AS iws
          ON ws.ws_item_sk = iws.i_item_sk
        JOIN date_dim AS d3
          ON ws.ws_sold_date_sk = d3.d_date_sk
        WHERE
          d3.d_year BETWEEN 1999 AND 2001
          AND iws.i_brand_id = iss.i_brand_id
          AND iws.i_class_id = iss.i_class_id
          AND iws.i_category_id = iss.i_category_id
      )
  ) AS t1
    ON i.i_brand_id = t1.brand_id
    AND i.i_class_id = t1.class_id
    AND i.i_category_id = t1.category_id
), avg_sales AS (
  SELECT
    AVG(quantity * list_price) AS average_sales
  FROM (
    SELECT
      ss_quantity AS quantity,
      ss_list_price AS list_price
    FROM store_sales AS ss
    JOIN date_dim AS dd
      ON ss.ss_sold_date_sk = dd.d_date_sk
    WHERE
      dd.d_year BETWEEN 1999 AND 2001
    UNION ALL
    SELECT
      cs_quantity AS quantity,
      cs_list_price AS list_price
    FROM catalog_sales AS cs
    JOIN date_dim AS dd
      ON cs.cs_sold_date_sk = dd.d_date_sk
    WHERE
      dd.d_year BETWEEN 1999 AND 2001
    UNION ALL
    SELECT
      ws_quantity AS quantity,
      ws_list_price AS list_price
    FROM web_sales AS ws
    JOIN date_dim AS dd
      ON ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
      dd.d_year BETWEEN 1999 AND 2001
  ) AS x
)
SELECT
  channel,
  i_brand_id,
  i_class_id,
  i_category_id,
  SUM(sales),
  SUM(number_sales)
FROM (
  SELECT
    'store' AS channel,
    i.i_brand_id,
    i.i_class_id,
    i.i_category_id,
    SUM(ss.ss_quantity * ss.ss_list_price) AS sales,
    COUNT(*) AS number_sales
  FROM store_sales AS ss
  JOIN item AS i
    ON ss.ss_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON ss.ss_sold_date_sk = dd.d_date_sk
  WHERE
    ss.ss_item_sk IN (
      SELECT
        ss_item_sk
      FROM cross_items
    )
    AND dd.d_year = 2001
    AND dd.d_moy = 11
  GROUP BY
    i.i_brand_id,
    i.i_class_id,
    i.i_category_id
  HAVING
    SUM(ss.ss_quantity * ss.ss_list_price) > (
      SELECT
        average_sales
      FROM avg_sales
    )
  UNION ALL
  SELECT
    'catalog' AS channel,
    i.i_brand_id,
    i.i_class_id,
    i.i_category_id,
    SUM(cs.cs_quantity * cs.cs_list_price) AS sales,
    COUNT(*) AS number_sales
  FROM catalog_sales AS cs
  JOIN item AS i
    ON cs.cs_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON cs.cs_sold_date_sk = dd.d_date_sk
  WHERE
    cs.cs_item_sk IN (
      SELECT
        ss_item_sk
      FROM cross_items
    )
    AND dd.d_year = 2001
    AND dd.d_moy = 11
  GROUP BY
    i.i_brand_id,
    i.i_class_id,
    i.i_category_id
  HAVING
    SUM(cs.cs_quantity * cs.cs_list_price) > (
      SELECT
        average_sales
      FROM avg_sales
    )
  UNION ALL
  SELECT
    'web' AS channel,
    i.i_brand_id,
    i.i_class_id,
    i.i_category_id,
    SUM(ws.ws_quantity * ws.ws_list_price) AS sales,
    COUNT(*) AS number_sales
  FROM web_sales AS ws
  JOIN item AS i
    ON ws.ws_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON ws.ws_sold_date_sk = dd.d_date_sk
  WHERE
    ws.ws_item_sk IN (
      SELECT
        ss_item_sk
      FROM cross_items
    )
    AND dd.d_year = 2001
    AND dd.d_moy = 11
  GROUP BY
    i.i_brand_id,
    i.i_class_id,
    i.i_category_id
  HAVING
    SUM(ws.ws_quantity * ws.ws_list_price) > (
      SELECT
        average_sales
      FROM avg_sales
    )
) AS y
GROUP BY
  channel,
  i_brand_id,
  i_class_id,
  i_category_id
WITH ROLLUP
ORDER BY
  channel,
  i_brand_id,
  i_class_id,
  i_category_id
LIMIT 100
;
