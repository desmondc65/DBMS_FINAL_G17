WITH DateRange AS (
    SELECT CAST('1999-02-22' AS DATE) AS start_date,
           DATE_ADD(CAST('1999-02-22' AS DATE), INTERVAL 90 DAY) AS end_date
),
AvgDiscount AS (
    SELECT 1.3 * AVG(cs.cs_ext_discount_amt) AS avg_discount
    FROM catalog_sales cs
    JOIN DateRange dr ON cs.cs_sold_date_sk = (SELECT d_date_sk FROM date_dim WHERE d_date = dr.start_date)
    WHERE cs.cs_sold_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_date BETWEEN dr.start_date AND dr.end_date)
)
SELECT SUM(cs.cs_ext_discount_amt) AS excess_discount_amount
FROM catalog_sales cs
JOIN item i ON cs.cs_item_sk = i.i_item_sk
JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk
JOIN DateRange dr ON dd.d_date BETWEEN dr.start_date AND dr.end_date
JOIN AvgDiscount ad ON 1=1  -- Cross join to access the calculated average
WHERE i.i_manufact_id = 283
  AND cs.cs_ext_discount_amt > ad.avg_discount
LIMIT 100;
