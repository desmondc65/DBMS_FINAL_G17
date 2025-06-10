SELECT
    AVG(CASE WHEN ss_quantity BETWEEN 0 AND 5 THEN ss_list_price ELSE NULL END) AS B1_LP,
    COUNT(CASE WHEN ss_quantity BETWEEN 0 AND 5 THEN ss_list_price ELSE NULL END) AS B1_CNT,
    COUNT(DISTINCT CASE WHEN ss_quantity BETWEEN 0 AND 5 THEN ss_list_price ELSE NULL END) AS B1_CNTD,
    AVG(CASE WHEN ss_quantity BETWEEN 6 AND 10 THEN ss_list_price ELSE NULL END) AS B2_LP,
    COUNT(CASE WHEN ss_quantity BETWEEN 6 AND 10 THEN ss_list_price ELSE NULL END) AS B2_CNT,
    COUNT(DISTINCT CASE WHEN ss_quantity BETWEEN 6 AND 10 THEN ss_list_price ELSE NULL END) AS B2_CNTD,
    AVG(CASE WHEN ss_quantity BETWEEN 11 AND 15 THEN ss_list_price ELSE NULL END) AS B3_LP,
    COUNT(CASE WHEN ss_quantity BETWEEN 11 AND 15 THEN ss_list_price ELSE NULL END) AS B3_CNT,
    COUNT(DISTINCT CASE WHEN ss_quantity BETWEEN 11 AND 15 THEN ss_list_price ELSE NULL END) AS B3_CNTD,
    AVG(CASE WHEN ss_quantity BETWEEN 16 AND 20 THEN ss_list_price ELSE NULL END) AS B4_LP,
    COUNT(CASE WHEN ss_quantity BETWEEN 16 AND 20 THEN ss_list_price ELSE NULL END) AS B4_CNT,
    COUNT(DISTINCT CASE WHEN ss_quantity BETWEEN 16 AND 20 THEN ss_list_price ELSE NULL END) AS B4_CNTD,
    AVG(CASE WHEN ss_quantity BETWEEN 21 AND 25 THEN ss_list_price ELSE NULL END) AS B5_LP,
    COUNT(CASE WHEN ss_quantity BETWEEN 21 AND 25 THEN ss_list_price ELSE NULL END) AS B5_CNT,
    COUNT(DISTINCT CASE WHEN ss_quantity BETWEEN 21 AND 25 THEN ss_list_price ELSE NULL END) AS B5_CNTD,
    AVG(CASE WHEN ss_quantity BETWEEN 26 AND 30 THEN ss_list_price ELSE NULL END) AS B6_LP,
    COUNT(CASE WHEN ss_quantity BETWEEN 26 AND 30 THEN ss_list_price ELSE NULL END) AS B6_CNT,
    COUNT(DISTINCT CASE WHEN ss_quantity BETWEEN 26 AND 30 THEN ss_list_price ELSE NULL END) AS B6_CNTD
FROM
    store_sales
WHERE
    (ss_quantity BETWEEN 0 AND 5 AND (ss_list_price BETWEEN 28 AND 38 OR ss_coupon_amt BETWEEN 12573 AND 13573+1000 OR ss_wholesale_cost BETWEEN 33 AND 53))
    OR (ss_quantity BETWEEN 6 AND 10 AND (ss_list_price BETWEEN 143 AND 153 OR ss_coupon_amt BETWEEN 5562 AND 6562 OR ss_wholesale_cost BETWEEN 45 AND 65))
    OR (ss_quantity BETWEEN 11 AND 15 AND (ss_list_price BETWEEN 159 AND 169 OR ss_coupon_amt BETWEEN 2807 AND 3807 OR ss_wholesale_cost BETWEEN 24 AND 44))
    OR (ss_quantity BETWEEN 16 AND 20 AND (ss_list_price BETWEEN 24 AND 34 OR ss_coupon_amt BETWEEN 3706 AND 4706 OR ss_wholesale_cost BETWEEN 46 AND 66))
    OR (ss_quantity BETWEEN 21 AND 25 AND (ss_list_price BETWEEN 76 AND 86 OR ss_coupon_amt BETWEEN 2096 AND 3096 OR ss_wholesale_cost BETWEEN 50 AND 70))
    OR (ss_quantity BETWEEN 26 AND 30 AND (ss_list_price BETWEEN 169 AND 179 OR ss_coupon_amt BETWEEN 10672 AND 11672 OR ss_wholesale_cost BETWEEN 58 AND 78))
LIMIT 100;
