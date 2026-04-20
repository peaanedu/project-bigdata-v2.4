USE lab;

CREATE TABLE IF NOT EXISTS sales_orders_parquet
STORED AS PARQUET
AS
SELECT
  order_id,
  CAST(order_date AS DATE) AS order_date,
  region,
  customer,
  product,
  category,
  quantity,
  unit_price,
  sales_amount
FROM ext_sales_orders;
