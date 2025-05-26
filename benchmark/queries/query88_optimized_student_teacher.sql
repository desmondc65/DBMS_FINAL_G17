
CREATE INDEX idx_store_name ON store (s_store_name);
CREATE INDEX idx_time_sk ON time_dim (t_time_sk, t_hour, t_minute); -- Composite index
CREATE INDEX idx_hdemo_sk ON household_demographics (hd_demo_sk, hd_dep_count, hd_vehicle_count); -- Composite index
CREATE INDEX idx_ss_sold_time_sk ON store_sales (ss_sold_time_sk, ss_hdemo_sk, ss_store_sk); -- Composite index
CREATE INDEX idx_store_sk ON store_sales (ss_store_sk);
CREATE INDEX idx_hdemo_sk_sales ON store_sales (ss_hdemo_sk);

WITH FilteredSales AS (
    SELECT ss.ss_sold_time_sk, ss.ss_hdemo_sk, ss.ss_store_sk
    FROM store_sales ss
    WHERE ss.ss_store_sk IN (SELECT s_store_sk FROM store WHERE s_store_name = 'ese')
)
SELECT
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 8 * 60 + 30 AND t.t_hour * 60 + t.t_minute < 9 * 60 THEN 1 ELSE 0 END) AS h8_30_to_9,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 9 * 60 AND t.t_hour * 60 + t.t_minute < 9 * 60 + 30 THEN 1 ELSE 0 END) AS h9_to_9_30,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 9 * 60 + 30 AND t.t_hour * 60 + t.t_minute < 10 * 60 THEN 1 ELSE 0 END) AS h9_30_to_10,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 10 * 60 AND t.t_hour * 60 + t.t_minute < 10 * 60 + 30 THEN 1 ELSE 0 END) AS h10_to_10_30,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 10 * 60 + 30 AND t.t_hour * 60 + t.t_minute < 11 * 60 THEN 1 ELSE 0 END) AS h10_30_to_11,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 11 * 60 AND t.t_hour * 60 + t.t_minute < 11 * 60 + 30 THEN 1 ELSE 0 END) AS h11_to_11_30,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 11 * 60 + 30 AND t.t_hour * 60 + t.t_minute < 12 * 60 THEN 1 ELSE 0 END) AS h11_30_to_12,
    SUM(CASE WHEN t.t_hour * 60 + t.t_minute >= 12 * 60 AND t.t_hour * 60 + t.t_minute < 12 * 60 + 30 THEN 1 ELSE 0 END) AS h12_to_12_30
FROM
    FilteredSales ss
JOIN
    time_dim t ON ss.ss_sold_time_sk = t.t_time_sk
JOIN
    household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
WHERE
    ((hd.hd_dep_count = 2 AND hd.hd_vehicle_count <= 4) OR
         (hd.hd_dep_count = 1 AND hd.hd_vehicle_count <= 3) OR
         (hd.hd_dep_count = 4 AND hd.hd_vehicle_count <= 6))
