SELECT c_customer_id,
       c_salutation,
       c_first_name,
       c_last_name,
       c_preferred_cust_flag,
       c_birth_day,
       c_birth_month,
       c_birth_year,
       c_birth_country,
       c_login,
       c_email_address,
       c_last_review_date_sk,
       ctr1.ctr_total_return
FROM customer_total_return ctr1
JOIN customer c ON ctr1.ctr_customer_sk = c.c_customer_sk
JOIN customer_address ca ON ca_address_sk = c.c_current_addr_sk
WHERE ca_state = 'KS'
  AND ctr1.ctr_total_return >
    (SELECT avg(ctr2.ctr_total_return)*1.2
     FROM customer_total_return ctr2
     WHERE ctr1.ctr_state = ctr2.ctr_state)
ORDER BY c_customer_id,
         c_salutation,
         c_first_name,
         c_last_name,
         c_preferred_cust_flag,
         c_birth_day,
         c_birth_month,
         c_birth_year,
         c_birth_country,
         c_login,
         c_email_address,
         c_last_review_date_sk,
         ctr1.ctr_total_return
LIMIT 100;
