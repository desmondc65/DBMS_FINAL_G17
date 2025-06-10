WITH QuantityBuckets AS (
    SELECT
        SUM(CASE WHEN ss_quantity BETWEEN 1 AND 20 THEN 1 ELSE 0 END) AS count_1_20,
        AVG(CASE WHEN ss_quantity BETWEEN 1 AND 20 THEN ss_ext_discount_amt ELSE NULL END) AS avg_discount_1_20,
        AVG(CASE WHEN ss_quantity BETWEEN 1 AND 20 THEN ss_net_profit ELSE NULL END) AS avg_profit_1_20,

        SUM(CASE WHEN ss_quantity BETWEEN 21 AND 40 THEN 1 ELSE 0 END) AS count_21_40,
        AVG(CASE WHEN ss_quantity BETWEEN 21 AND 40 THEN ss_ext_discount_amt ELSE NULL END) AS avg_discount_21_40,
        AVG(CASE WHEN ss_quantity BETWEEN 21 AND 40 THEN ss_net_profit ELSE NULL END) AS avg_profit_21_40,

        SUM(CASE WHEN ss_quantity BETWEEN 41 AND 60 THEN 1 ELSE 0 END) AS count_41_60,
        AVG(CASE WHEN ss_quantity BETWEEN 41 AND 60 THEN ss_ext_discount_amt ELSE NULL END) AS avg_discount_41_60,
        AVG(CASE WHEN ss_quantity BETWEEN 41 AND 60 THEN ss_net_profit ELSE NULL END) AS avg_profit_41_60,

        SUM(CASE WHEN ss_quantity BETWEEN 61 AND 80 THEN 1 ELSE 0 END) AS count_61_80,
        AVG(CASE WHEN ss_quantity BETWEEN 61 AND 80 THEN ss_ext_discount_amt ELSE NULL END) AS avg_discount_61_80,
        AVG(CASE WHEN ss_quantity BETWEEN 61 AND 80 THEN ss_net_profit ELSE NULL END) AS avg_profit_61_80,

        SUM(CASE WHEN ss_quantity BETWEEN 81 AND 100 THEN 1 ELSE 0 END) AS count_81_100,
        AVG(CASE WHEN ss_quantity BETWEEN 81 AND 100 THEN ss_ext_discount_amt ELSE NULL END) AS avg_discount_81_100,
        AVG(CASE WHEN ss_quantity BETWEEN 81 AND 100 THEN ss_net_profit ELSE NULL END) AS avg_profit_81_100
    FROM store_sales
)
SELECT
    CASE WHEN count_1_20 > 31002 THEN avg_discount_1_20 ELSE avg_profit_1_20 END AS bucket1,
    CASE WHEN count_21_40 > 588 THEN avg_discount_21_40 ELSE avg_profit_21_40 END AS bucket2,
    CASE WHEN count_41_60 > 2456 THEN avg_discount_41_60 ELSE avg_profit_41_60 END AS bucket3,
    CASE WHEN count_61_80 > 21645 THEN avg_discount_61_80 ELSE avg_profit_61_80 END AS bucket4,
    CASE WHEN count_81_100 > 20553 THEN avg_discount_81_100 ELSE avg_profit_81_100 END AS bucket5
FROM QuantityBuckets;
