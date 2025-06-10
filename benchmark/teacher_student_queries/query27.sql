SELECT
    i.i_item_id,
    s.s_state,
    GROUPING(s.s_state) AS g_state,
    AVG(ss.ss_quantity) AS agg1,
    AVG(ss.ss_list_price) AS agg2,
    AVG(ss.ss_coupon_amt) AS agg3,
    AVG(ss.ss_sales_price) AS agg4
FROM
    store_sales ss
JOIN
    item i ON ss.ss_item_sk = i.i_item_sk
JOIN
    store s ON ss.ss_store_sk = s.s_store_sk
JOIN
    date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
JOIN
    customer_demographics cd ON ss.ss_cdemo_sk = cd.cd_demo_sk
WHERE
    cd.cd_gender = 'M'
    AND cd.cd_marital_status = 'U'
    AND cd.cd_education_status = 'Secondary'
    AND d.d_year = 2000
    AND s.s_state = 'TN'
GROUP BY
    i.i_item_id, s.s_state WITH ROLLUP
ORDER BY
    i.i_item_id, s.s_state
LIMIT 100;
