from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date

spark = (
    SparkSession.builder
    .appName("sales-orders-etl")
    .master("spark://spark-master:7077")
    .config("spark.hadoop.fs.defaultFS", "hdfs://namenode:9000")
    .config("hive.metastore.uris", "thrift://hive-metastore:9083")
    .config("spark.sql.warehouse.dir", "hdfs://namenode:9000/user/hive/warehouse")
    .enableHiveSupport()
    .getOrCreate()
)

input_path = "hdfs://namenode:9000/data/raw/sales/sales_orders.csv"
output_path = "hdfs://namenode:9000/data/curated/sales_orders_parquet"

df = (
    spark.read
    .option("header", True)
    .csv(input_path)
    .withColumn("order_id", col("order_id").cast("int"))
    .withColumn("order_date", to_date(col("order_date"), "yyyy-MM-dd"))
    .withColumn("quantity", col("quantity").cast("int"))
    .withColumn("unit_price", col("unit_price").cast("double"))
    .withColumn("sales_amount", col("sales_amount").cast("double"))
)

(
    df.write
    .mode("overwrite")
    .parquet(output_path)
)

spark.sql("CREATE DATABASE IF NOT EXISTS lab")
spark.sql("DROP TABLE IF EXISTS lab.sales_orders_curated")
spark.sql(f"""
CREATE EXTERNAL TABLE lab.sales_orders_curated (
  order_id INT,
  order_date DATE,
  region STRING,
  customer STRING,
  product STRING,
  category STRING,
  quantity INT,
  unit_price DOUBLE,
  sales_amount DOUBLE
)
STORED AS PARQUET
LOCATION '{output_path}'
""")

spark.sql("SELECT region, SUM(sales_amount) AS total_sales FROM lab.sales_orders_curated GROUP BY region").show()

spark.stop()
