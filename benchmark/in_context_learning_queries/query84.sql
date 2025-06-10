SELECT c_customer_id AS customer_id,
       concat(COALESCE(c_last_name, ''), ', ', COALESCE(c_first_name, '')) AS customername
FROM customer AS c
JOIN customer_address AS ca ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics AS cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
JOIN household_demographics AS hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
JOIN income_band AS ib ON hd.hd_income_band_sk = ib.ib_income_band_sk
JOIN store_returns AS sr ON cd.cd_demo_sk = sr.sr_cdemo_sk
WHERE ca_city = 'White Oak'
  AND ib_lower_bound >= 45626
  AND ib_upper_bound <= 50626
ORDER BY c_customer_id
LIMIT 100;
