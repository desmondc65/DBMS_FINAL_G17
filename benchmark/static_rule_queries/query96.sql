SELECT count(*)
FROM store_sales AS ss
JOIN household_demographics AS hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
JOIN time_dim AS t ON ss.ss_sold_time_sk = t.t_time_sk
JOIN store AS s ON ss.ss_store_sk = s.s_store_sk
WHERE t.t_hour = 8
AND t.t_minute >= 30
AND hd.hd_dep_count = 5
AND s.s_store_name = 'ese';
