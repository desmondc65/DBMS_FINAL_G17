WITH wss AS (
  SELECT
    d_week_seq,
    ss_store_sk,
    SUM(CASE WHEN d_day_name = 'Sunday' THEN ss_sales_price ELSE NULL END) AS sun_sales,
    SUM(CASE WHEN d_day_name = 'Monday' THEN ss_sales_price ELSE NULL END) AS mon_sales,
    SUM(CASE WHEN d_day_name = 'Tuesday' THEN ss_sales_price ELSE NULL END) AS tue_sales,
    SUM(CASE WHEN d_day_name = 'Wednesday' THEN ss_sales_price ELSE NULL END) AS wed_sales,
    SUM(CASE WHEN d_day_name = 'Thursday' THEN ss_sales_price ELSE NULL END) AS thu_sales,
    SUM(CASE WHEN d_day_name = 'Friday' THEN ss_sales_price ELSE NULL END) AS fri_sales,
    SUM(CASE WHEN d_day_name = 'Saturday' THEN ss_sales_price ELSE NULL END) AS sat_sales
  FROM store_sales AS ss
  JOIN date_dim AS dd
    ON dd.d_date_sk = ss.ss_sold_date_sk
  GROUP BY
    d_week_seq,
    ss_store_sk
)
SELECT
  y.s_store_name1,
  y.s_store_id1,
  y.d_week_seq1,
  y.sun_sales1 / x.sun_sales2,
  y.mon_sales1 / x.mon_sales2,
  y.tue_sales1 / x.tue_sales2,
  y.wed_sales1 / x.wed_sales2,
  y.thu_sales1 / x.thu_sales2,
  y.fri_sales1 / x.fri_sales2,
  y.sat_sales1 / x.sat_sales2
FROM (
  SELECT
    s.s_store_name AS s_store_name1,
    wss.d_week_seq AS d_week_seq1,
    s.s_store_id AS s_store_id1,
    wss.sun_sales AS sun_sales1,
    wss.mon_sales AS mon_sales1,
    wss.tue_sales AS tue_sales1,
    wss.wed_sales AS wed_sales1,
    wss.thu_sales AS thu_sales1,
    wss.fri_sales AS fri_sales1,
    wss.sat_sales AS sat_sales1
  FROM wss
  JOIN store AS s
    ON wss.ss_store_sk = s.s_store_sk
  JOIN date_dim AS d
    ON d.d_week_seq = wss.d_week_seq
  WHERE
    d.d_month_seq BETWEEN 1206 AND 1217
) AS y
JOIN (
  SELECT
    s.s_store_name AS s_store_name2,
    wss.d_week_seq AS d_week_seq2,
    s.s_store_id AS s_store_id2,
    wss.sun_sales AS sun_sales2,
    wss.mon_sales AS mon_sales2,
    wss.tue_sales AS tue_sales2,
    wss.wed_sales AS wed_sales2,
    wss.thu_sales AS thu_sales2,
    wss.fri_sales AS fri_sales2,
    wss.sat_sales AS sat_sales2
  FROM wss
  JOIN store AS s
    ON wss.ss_store_sk = s.s_store_sk
  JOIN date_dim AS d
    ON d.d_week_seq = wss.d_week_seq
  WHERE
    d.d_month_seq BETWEEN 1218 AND 1229
) AS x
  ON y.s_store_id1 = x.s_store_id2
  AND y.d_week_seq1 = x.d_week_seq2 - 52
ORDER BY
  s_store_name1,
  s_store_id1,
  d_week_seq1
LIMIT 100
