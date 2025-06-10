WITH sr_items AS (
  SELECT
    i.i_item_id AS item_id,
    SUM(sr.sr_return_quantity) AS sr_item_qty
  FROM store_returns AS sr
  JOIN item AS i
    ON sr.sr_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON sr.sr_returned_date_sk = dd.d_date_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM date_dim AS dd2
      WHERE
        dd2.d_date IN ('2000-04-29', '2000-09-09', '2000-11-02')
        AND dd2.d_week_seq = dd.d_week_seq
    )
  GROUP BY
    i.i_item_id
), cr_items AS (
  SELECT
    i.i_item_id AS item_id,
    SUM(cr.cr_return_quantity) AS cr_item_qty
  FROM catalog_returns AS cr
  JOIN item AS i
    ON cr.cr_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON cr.cr_returned_date_sk = dd.d_date_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM date_dim AS dd2
      WHERE
        dd2.d_date IN ('2000-04-29', '2000-09-09', '2000-11-02')
        AND dd2.d_week_seq = dd.d_week_seq
    )
  GROUP BY
    i.i_item_id
), wr_items AS (
  SELECT
    i.i_item_id AS item_id,
    SUM(wr.wr_return_quantity) AS wr_item_qty
  FROM web_returns AS wr
  JOIN item AS i
    ON wr.wr_item_sk = i.i_item_sk
  JOIN date_dim AS dd
    ON wr.wr_returned_date_sk = dd.d_date_sk
  WHERE
    EXISTS(
      SELECT
        1
      FROM date_dim AS dd2
      WHERE
        dd2.d_date IN ('2000-04-29', '2000-09-09', '2000-11-02')
        AND dd2.d_week_seq = dd.d_week_seq
    )
  GROUP BY
    i.i_item_id
)
SELECT
  sr.item_id,
  sr.sr_item_qty,
  sr.sr_item_qty / (sr.sr_item_qty + cr.cr_item_qty + wr.wr_item_qty) / 3.0 * 100 AS sr_dev,
  cr.cr_item_qty,
  cr.cr_item_qty / (sr.sr_item_qty + cr.cr_item_qty + wr.wr_item_qty) / 3.0 * 100 AS cr_dev,
  wr.wr_item_qty,
  wr.wr_item_qty / (sr.sr_item_qty + cr.cr_item_qty + wr.wr_item_qty) / 3.0 * 100 AS wr_dev,
  (
    sr.sr_item_qty + cr.cr_item_qty + wr.wr_item_qty
  ) / 3.0 AS average
FROM sr_items AS sr
JOIN cr_items AS cr
  ON sr.item_id = cr.item_id
JOIN wr_items AS wr
  ON sr.item_id = wr.item_id
ORDER BY
  sr.item_id,
  sr.sr_item_qty
LIMIT 100
