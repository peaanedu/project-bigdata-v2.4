USE lab;

CREATE EXTERNAL TABLE IF NOT EXISTS ext_sales_orders (
  order_id INT,
  order_date STRING,
  region STRING,
  customer STRING,
  product STRING,
  category STRING,
  quantity INT,
  unit_price DOUBLE,
  sales_amount DOUBLE
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar" = "\"",
  "escapeChar" = "\\"
)
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/data/raw/sales'
TBLPROPERTIES ("skip.header.line.count"="1");
