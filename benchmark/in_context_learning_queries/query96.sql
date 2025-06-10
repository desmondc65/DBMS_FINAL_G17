SELECT count(*)
FROM store_sales AS ss
JOIN household_demographics AS hd ON ss_hdemo_sk = hd_demo_sk
JOIN time_dim AS td ON ss_sold_time_sk = t_time_sk
JOIN store AS s ON ss_store_sk = s_store_sk
WHERE t_hour = 8
  AND t_minute >= 30
  AND hd_dep_count = 5
  AND s_store_name = 'ese';
