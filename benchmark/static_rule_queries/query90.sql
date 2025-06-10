SELECT
  CAST(amc AS DECIMAL(15, 4)) / CAST(pmc AS DECIMAL(15, 4)) AS am_pm_ratio
FROM (
  SELECT
    COUNT(*) AS amc
  FROM web_sales AS ws
  JOIN time_dim AS td
    ON ws.ws_sold_time_sk = td.t_time_sk
  JOIN household_demographics AS hd
    ON ws.ws_ship_hdemo_sk = hd.hd_demo_sk
  JOIN web_page AS wp
    ON ws.ws_web_page_sk = wp.wp_web_page_sk
  WHERE
    td.t_hour BETWEEN 9 AND 10
    AND hd.hd_dep_count = 2
    AND wp.wp_char_count BETWEEN 5000 AND 5200
) AS at, (
  SELECT
    COUNT(*) AS pmc
  FROM web_sales AS ws
  JOIN time_dim AS td
    ON ws.ws_sold_time_sk = td.t_time_sk
  JOIN household_demographics AS hd
    ON ws.ws_ship_hdemo_sk = hd.hd_demo_sk
  JOIN web_page AS wp
    ON ws.ws_web_page_sk = wp.wp_web_page_sk
  WHERE
    td.t_hour BETWEEN 15 AND 16
    AND hd.hd_dep_count = 2
    AND wp.wp_char_count BETWEEN 5000 AND 5200
) AS pt
ORDER BY
  am_pm_ratio
LIMIT 100
