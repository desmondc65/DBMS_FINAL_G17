WITH all_sales AS (
  SELECT
    d_year,
    i_brand_id,
    i_class_id,
    i_category_id,
    i_manufact_id,
    SUM(sales_cnt) AS sales_cnt,
    SUM(sales_amt) AS sales_amt
  FROM (
    SELECT
      d_year,
      i_brand_id,
      i_class_id,
      i_category_id,
      i_manufact_id,
      cs_quantity - COALESCE(cr_return_quantity, 0) AS sales_cnt,
      cs_ext_sales_price - COALESCE(cr_return_amount, 0.0) AS sales_amt
    FROM catalog_sales AS CS
    JOIN item AS I
      ON I.i_item_sk = CS.cs_item_sk
    JOIN date_dim AS DD
      ON DD.d_date_sk = CS.cs_sold_date_sk
    LEFT JOIN catalog_returns AS CR
      ON CS.cs_order_number = CR.cr_order_number
      AND CS.cs_item_sk = CR.cr_item_sk
    WHERE
      I.i_category = 'Shoes'
    UNION ALL
    SELECT
      d_year,
      i_brand_id,
      i_class_id,
      i_category_id,
      i_manufact_id,
      ss_quantity - COALESCE(sr_return_quantity, 0) AS sales_cnt,
      ss_ext_sales_price - COALESCE(sr_return_amt, 0.0) AS sales_amt
    FROM store_sales AS SS
    JOIN item AS I
      ON I.i_item_sk = SS.ss_item_sk
    JOIN date_dim AS DD
      ON DD.d_date_sk = SS.ss_sold_date_sk
    LEFT JOIN store_returns AS SR
      ON SS.ss_ticket_number = SR.sr_ticket_number
      AND SS.ss_item_sk = SR.sr_item_sk
    WHERE
      I.i_category = 'Shoes'
    UNION ALL
    SELECT
      d_year,
      i_brand_id,
      i_class_id,
      i_category_id,
      i_manufact_id,
      ws_quantity - COALESCE(wr_return_quantity, 0) AS sales_cnt,
      ws_ext_sales_price - COALESCE(wr_return_amt, 0.0) AS sales_amt
    FROM web_sales AS WS
    JOIN item AS I
      ON I.i_item_sk = WS.ws_item_sk
    JOIN date_dim AS DD
      ON DD.d_date_sk = WS.ws_sold_date_sk
    LEFT JOIN web_returns AS WR
      ON WS.ws_order_number = WR.wr_order_number
      AND WS.ws_item_sk = WR.wr_item_sk
    WHERE
      I.i_category = 'Shoes'
  ) AS sales_detail
  GROUP BY
    d_year,
    i_brand_id,
    i_class_id,
    i_category_id,
    i_manufact_id
)
SELECT
  prev_yr.d_year AS prev_year,
  curr_yr.d_year AS year,
  curr_yr.i_brand_id,
  curr_yr.i_class_id,
  curr_yr.i_category_id,
  curr_yr.i_manufact_id,
  prev_yr.sales_cnt AS prev_yr_cnt,
  curr_yr.sales_cnt AS curr_yr_cnt,
  curr_yr.sales_cnt - prev_yr.sales_cnt AS sales_cnt_diff,
  curr_yr.sales_amt - prev_yr.sales_amt AS sales_amt_diff
FROM all_sales AS curr_yr
JOIN all_sales AS prev_yr
  ON curr_yr.i_brand_id = prev_yr.i_brand_id
  AND curr_yr.i_class_id = prev_yr.i_class_id
  AND curr_yr.i_category_id = prev_yr.i_category_id
  AND curr_yr.i_manufact_id = prev_yr.i_manufact_id
WHERE
  curr_yr.d_year = 2000
  AND prev_yr.d_year = 1999
  AND curr_yr.sales_cnt / prev_yr.sales_cnt < 0.9
ORDER BY
  sales_cnt_diff,
  sales_amt_diff
LIMIT 100
