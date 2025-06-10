SELECT
  s1.h8_30_to_9,
  s2.h9_to_9_30,
  s3.h9_30_to_10,
  s4.h10_to_10_30,
  s5.h10_30_to_11,
  s6.h11_to_11_30,
  s7.h11_30_to_12,
  s8.h12_to_12_30
FROM
  (
    SELECT
      COUNT(*) AS h8_30_to_9
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 8
      AND td.t_minute >= 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s1,
  (
    SELECT
      COUNT(*) AS h9_to_9_30
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 9
      AND td.t_minute < 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s2,
  (
    SELECT
      COUNT(*) AS h9_30_to_10
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 9
      AND td.t_minute >= 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s3,
  (
    SELECT
      COUNT(*) AS h10_to_10_30
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 10
      AND td.t_minute < 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s4,
  (
    SELECT
      COUNT(*) AS h10_30_to_11
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 10
      AND td.t_minute >= 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s5,
  (
    SELECT
      COUNT(*) AS h11_to_11_30
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 11
      AND td.t_minute < 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s6,
  (
    SELECT
      COUNT(*) AS h11_30_to_12
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 11
      AND td.t_minute >= 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s7,
  (
    SELECT
      COUNT(*) AS h12_to_12_30
    FROM store_sales AS ss
    JOIN household_demographics AS hd
      ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN time_dim AS td
      ON ss.ss_sold_time_sk = td.t_time_sk
    JOIN store AS s
      ON ss.ss_store_sk = s.s_store_sk
    WHERE
      td.t_hour = 12
      AND td.t_minute < 30
      AND (
        hd.hd_dep_count = 2
        AND hd.hd_vehicle_count <= 4
        OR hd.hd_dep_count = 1
        AND hd.hd_vehicle_count <= 3
        OR hd.hd_dep_count = 4
        AND hd.hd_vehicle_count <= 6
      )
      AND s.s_store_name = 'ese'
  ) AS s8
