SELECT
  B1.B1_LP,
  B1.B1_CNT,
  B1.B1_CNTD,
  B2.B2_LP,
  B2.B2_CNT,
  B2.B2_CNTD,
  B3.B3_LP,
  B3.B3_CNT,
  B3.B3_CNTD,
  B4.B4_LP,
  B4.B4_CNT,
  B4.B4_CNTD,
  B5.B5_LP,
  B5.B5_CNT,
  B5.B5_CNTD,
  B6.B6_LP,
  B6.B6_CNT,
  B6.B6_CNTD
FROM (
  SELECT
    AVG(ss_list_price) AS B1_LP,
    COUNT(ss_list_price) AS B1_CNT,
    COUNT(DISTINCT ss_list_price) AS B1_CNTD
  FROM store_sales
  WHERE
    ss_quantity BETWEEN 0 AND 5
    AND (
      ss_list_price BETWEEN 28 AND 38
      OR ss_coupon_amt BETWEEN 12573 AND 13573
      OR ss_wholesale_cost BETWEEN 33 AND 53
    )
) AS B1, (
  SELECT
    AVG(ss_list_price) AS B2_LP,
    COUNT(ss_list_price) AS B2_CNT,
    COUNT(DISTINCT ss_list_price) AS B2_CNTD
  FROM store_sales
  WHERE
    ss_quantity BETWEEN 6 AND 10
    AND (
      ss_list_price BETWEEN 143 AND 153
      OR ss_coupon_amt BETWEEN 5562 AND 6562
      OR ss_wholesale_cost BETWEEN 45 AND 65
    )
) AS B2, (
  SELECT
    AVG(ss_list_price) AS B3_LP,
    COUNT(ss_list_price) AS B3_CNT,
    COUNT(DISTINCT ss_list_price) AS B3_CNTD
  FROM store_sales
  WHERE
    ss_quantity BETWEEN 11 AND 15
    AND (
      ss_list_price BETWEEN 159 AND 169
      OR ss_coupon_amt BETWEEN 2807 AND 3807
      OR ss_wholesale_cost BETWEEN 24 AND 44
    )
) AS B3, (
  SELECT
    AVG(ss_list_price) AS B4_LP,
    COUNT(ss_list_price) AS B4_CNT,
    COUNT(DISTINCT ss_list_price) AS B4_CNTD
  FROM store_sales
  WHERE
    ss_quantity BETWEEN 16 AND 20
    AND (
      ss_list_price BETWEEN 24 AND 34
      OR ss_coupon_amt BETWEEN 3706 AND 4706
      OR ss_wholesale_cost BETWEEN 46 AND 66
    )
) AS B4, (
  SELECT
    AVG(ss_list_price) AS B5_LP,
    COUNT(ss_list_price) AS B5_CNT,
    COUNT(DISTINCT ss_list_price) AS B5_CNTD
  FROM store_sales
  WHERE
    ss_quantity BETWEEN 21 AND 25
    AND (
      ss_list_price BETWEEN 76 AND 86
      OR ss_coupon_amt BETWEEN 2096 AND 3096
      OR ss_wholesale_cost BETWEEN 50 AND 70
    )
) AS B5, (
  SELECT
    AVG(ss_list_price) AS B6_LP,
    COUNT(ss_list_price) AS B6_CNT,
    COUNT(DISTINCT ss_list_price) AS B6_CNTD
  FROM store_sales
  WHERE
    ss_quantity BETWEEN 26 AND 30
    AND (
      ss_list_price BETWEEN 169 AND 179
      OR ss_coupon_amt BETWEEN 10672 AND 11672
      OR ss_wholesale_cost BETWEEN 58 AND 78
    )
) AS B6
LIMIT 100
