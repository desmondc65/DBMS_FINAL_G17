SELECT c_customer_id
FROM (
    SELECT sr_customer_sk, sr_store_sk, sum(SR_RETURN_AMT_INC_TAX) AS ctr_total_return
    FROM store_returns sr
    JOIN date_dim dd ON sr.sr_returned_date_sk = dd.d_date_sk
    WHERE dd.d_year = 1999
    GROUP BY sr_customer_sk, sr_store_sk
) ctr1
JOIN store s ON s_store_sk = ctr1.ctr_store_sk
JOIN customer c ON ctr1.ctr_customer_sk = c_customer_sk
WHERE ctr1.ctr_total_return > (
    SELECT avg(ctr_total_return) * 1.2
    FROM (
        SELECT sr_store_sk, sum(SR_RETURN_AMT_INC_TAX) AS ctr_total_return
        FROM store_returns sr
        JOIN date_dim dd ON sr.sr_returned_date_sk = dd.d_date_sk
        WHERE dd.d_year = 1999
        GROUP BY sr_store_sk
    ) AS ctr2
    WHERE ctr1.ctr_store_sk = ctr2.sr_store_sk
)
AND s_state = 'TN'
ORDER BY c_customer_id
LIMIT 100;
