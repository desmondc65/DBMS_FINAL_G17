SELECT avg(ss_quantity),
       avg(ss_ext_sales_price),
       avg(ss_ext_wholesale_cost),
       sum(ss_ext_wholesale_cost)
FROM store_sales ss
JOIN store s ON s.s_store_sk = ss.ss_store_sk
JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
JOIN customer_demographics cd ON ss.ss_cdemo_sk = cd.cd_demo_sk
JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
JOIN customer_address ca ON ss.ss_addr_sk = ca.ca_address_sk
WHERE d.d_year = 2001
  AND ((ss.ss_hdemo_sk = hd.hd_demo_sk
        AND ss.ss_cdemo_sk = cd.cd_demo_sk
        AND cd.cd_marital_status = 'U'
        AND cd.cd_education_status = '4 yr Degree'
        AND ss.ss_sales_price BETWEEN 100.00 AND 150.00
        AND hd.hd_dep_count = 3)
       OR (ss.ss_hdemo_sk = hd.hd_demo_sk
           AND ss.ss_cdemo_sk = cd.cd_demo_sk
           AND cd.cd_marital_status = 'S'
           AND cd.cd_education_status = 'Unknown'
           AND ss.ss_sales_price BETWEEN 50.00 AND 100.00
           AND hd.hd_dep_count = 1)
       OR (ss.ss_hdemo_sk = hd.hd_demo_sk
           AND ss.ss_cdemo_sk = cd.cd_demo_sk
           AND cd.cd_marital_status = 'D'
           AND cd.cd_education_status = '2 yr Degree'
           AND ss.ss_sales_price BETWEEN 150.00 AND 200.00
           AND hd.hd_dep_count = 1))
  AND ((ss.ss_addr_sk = ca.ca_address_sk
        AND ca.ca_country = 'United States'
        AND ca.ca_state IN ('CO',
                             'MI',
                             'MN')
        AND ss.ss_net_profit BETWEEN 100 AND 200)
       OR (ss.ss_addr_sk = ca.ca_address_sk
           AND ca.ca_country = 'United States'
           AND ca.ca_state IN ('NC',
                                'NY',
                                'TX')
           AND ss.ss_net_profit BETWEEN 150 AND 300)
       OR (ss.ss_addr_sk = ca.ca_address_sk
           AND ca.ca_country = 'United States'
           AND ca.ca_state IN ('CA',
                                'NE',
                                'TN')
           AND ss.ss_net_profit BETWEEN 50 AND 250));
