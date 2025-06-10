SELECT DISTINCT i_product_name
FROM item i1
WHERE i_manufact_id BETWEEN 668 AND 708
AND EXISTS (
  SELECT 1
  FROM item i2
  WHERE i2.i_manufact = i1.i_manufact
  AND (
    (
      i2.i_category = 'Women'
      AND (i2.i_color = 'cream' OR i2.i_color = 'ghost')
      AND (i2.i_units = 'Ton' OR i2.i_units = 'Gross')
      AND (i2.i_size = 'economy' OR i2.i_size = 'small')
    )
    OR (
      i2.i_category = 'Women'
      AND (i2.i_color = 'midnight' OR i2.i_color = 'burlywood')
      AND (i2.i_units = 'Tsp' OR i2.i_units = 'Bundle')
      AND (i2.i_size = 'medium' OR i2.i_size = 'extra large')
    )
    OR (
      i2.i_category = 'Men'
      AND (i2.i_color = 'lavender' OR i2.i_color = 'azure')
      AND (i2.i_units = 'Each' OR i2.i_units = 'Lb')
      AND (i2.i_size = 'large' OR i2.i_size = 'N/A')
    )
    OR (
      i2.i_category = 'Men'
      AND (i2.i_color = 'chocolate' OR i2.i_color = 'steel')
      AND (i2.i_units = 'N/A' OR i2.i_units = 'Dozen')
      AND (i2.i_size = 'economy' OR i2.i_size = 'small')
    )
  )
  OR (
    i2.i_manufact = i1.i_manufact
    AND (
      (
        i2.i_category = 'Women'
        AND (i2.i_color = 'floral' OR i2.i_color = 'royal')
        AND (i2.i_units = 'Unknown' OR i2.i_units = 'Tbl')
        AND (i2.i_size = 'economy' OR i2.i_size = 'small')
      )
      OR (
        i2.i_category = 'Women'
        AND (i2.i_color = 'navy' OR i2.i_color = 'forest')
        AND (i2.i_units = 'Bunch' OR i2.i_units = 'Dram')
        AND (i2.i_size = 'medium' OR i2.i_size = 'extra large')
      )
      OR (
        i2.i_category = 'Men'
        AND (i2.i_color = 'cyan' OR i2.i_color = 'indian')
        AND (i2.i_units = 'Carton' OR i2.i_units = 'Cup')
        AND (i2.i_size = 'large' OR i2.i_size = 'N/A')
      )
      OR (
        i2.i_category = 'Men'
        AND (i2.i_color = 'coral' OR i2.i_color = 'pale')
        AND (i2.i_units = 'Pallet' OR i2.i_units = 'Gram')
        AND (i2.i_size = 'economy' OR i2.i_size = 'small')
      )
    )
  )
)
ORDER BY i_product_name
LIMIT 100;
