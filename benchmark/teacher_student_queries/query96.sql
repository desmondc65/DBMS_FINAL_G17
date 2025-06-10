WITH TimeFilter AS (
    SELECT t_time_sk
    FROM time_dim
    WHERE t_hour = 8
    AND t_minute >= 30
),
HouseholdFilter AS (
    SELECT hd_demo_sk
    FROM household_demographics
    WHERE hd_dep_count = 5
),
StoreFilter AS (
    SELECT s_store_sk
    FROM store
    WHERE s_store_name = 'ese'
)
SELECT count(*)
FROM store_sales ss
JOIN TimeFilter td ON ss.ss_sold_time_sk = td.t_time_sk
JOIN HouseholdFilter hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
JOIN StoreFilter s ON ss.ss_store_sk = s.s_store_sk;
