# E-Commerce Data Pipeline - ETL Process Documentation

## Overview

This document provides a detailed walkthrough of the ETL (Extract, Transform, Load) process implemented in this data engineering project.

---

## 1. Bronze Layer: Data Ingestion

### Purpose

The Bronze layer serves as the raw data repository, capturing data exactly as it arrives from source systems without any transformations.

### Data Source

- **Type:** CSV (Comma-Separated Values)
- **Location:** `./data/bronze/ecommerce_sales_raw.csv`
- **Format:** Structured tabular data with headers
- **Volume:** ~15,000 transactions

### Processing Steps

#### 1.1 Data Reading

```python
df_raw = spark.read.csv(
    str(bronze_file),
    header=True,
    inferSchema=True
)
```

- Spark automatically infers schema from CSV headers
- `header=True` indicates first row contains column names
- `inferSchema=True` enables automatic type detection

#### 1.2 Initial Validation

- **Row Count:** Total records ingested
- **Schema Inspection:** Verify all expected columns present
- **Data Types:** Confirm inferred types are reasonable

#### 1.3 Quality Checks

- **Null Count:** Identify missing values per column
- **Duplicate Detection:** Find exact row duplicates
- **Schema Validation:** Ensure data structure integrity

### Output

- Raw data loaded into memory as Spark DataFrame
- Ready for transformation pipeline

---

## 2. Silver Layer: Data Transformation

### Purpose

Transform and clean raw data into a standardized, consistent format suitable for analytics.

### Key Transformations

#### 2.1 Deduplication

```python
df = df_raw.dropDuplicates(["order_id"])
```

**Logic:** Remove duplicate orders based on unique `order_id`

**Rationale:**

- `order_id` should be unique in order data
- Duplicates may result from source system errors or retries
- Deduplication ensures analytical accuracy

#### 2.2 Missing Value Imputation

```python
df = df.fillna({
    "city": "Unknown",
    "product_name": "Unknown",
    "discount": 0.0,
    "sales": 0.0
})
```

**Strategy:** Fill nulls with meaningful defaults based on column semantics

| Column         | Default   | Rationale                      |
| -------------- | --------- | ------------------------------ |
| `city`         | "Unknown" | Categorical - safe placeholder |
| `product_name` | "Unknown" | Categorical - preserves data   |
| `discount`     | 0.0       | Numeric - no discount if null  |
| `sales`        | 0.0       | Numeric - zero transaction     |

#### 2.3 Date Parsing

```python
df = df.withColumn(
    "order_date_parsed",
    to_date(col("order_date"), "dd-MM-yyyy")
)
df = df.filter(col("order_date_parsed").isNotNull())
```

**Transformation:**

1. Parse string date "15-01-2024" → Date type
2. Filter out unparseable dates (data quality check)

**Why:** Enables temporal analysis and prevents type errors

#### 2.4 Business Logic Validation

```python
df = df.filter(
    (col("quantity") >= 0) &
    (col("unit_price") >= 0) &
    (col("sales") >= 0)
)
```

**Rules:**

- Quantity cannot be negative (impossible transaction)
- Prices cannot be negative
- Sales amount cannot be negative

**Impact:** Removes ~5-10% of rows (typical data quality issues)

#### 2.5 Feature Engineering

```python
df = df \
    .withColumn("order_year", year(col("order_date_parsed"))) \
    .withColumn("order_month", month(col("order_date_parsed"))) \
    .withColumn("order_quarter", quarter(col("order_date_parsed"))) \
    .withColumn("order_day", dayofmonth(col("order_date_parsed")))
```

**Purpose:** Extract temporal components for time-based analysis

**Use Cases:**

- Monthly trend analysis
- Quarterly performance reporting
- Day-of-month seasonality patterns

#### 2.6 Calculated Columns

```python
df = df.withColumn("net_sales",
    round(col("sales") * (1 - col("discount") / 100), 2)
)
df = df.withColumn("profit_margin_pct",
    when(col("sales") > 0,
         round(col("profit") / col("sales") * 100, 2)
    ).otherwise(lit(0.0))
)
df = df.withColumn("revenue_bucket",
    when(col("sales") >= 100000, lit("High"))
    .when(col("sales") >= 30000, lit("Medium"))
    .otherwise(lit("Low"))
)
```

**Derived Metrics:**

- **Net Sales:** Account for discounts (Gross - Discount)
- **Profit Margin %:** Profitability metric
- **Revenue Bucket:** Categorical segmentation

#### 2.7 Metadata Columns

```python
df = df.withColumn("_silver_load_timestamp", current_timestamp()) \
       .withColumn("_silver_load_date", col("order_date_parsed"))
```

**Purpose:** Track data lineage and processing time

### Output Format

- **Format:** Delta Lake (Parquet-based)
- **Partitioning:** `order_year`, `order_month`
- **Location:** `./data/silver/ecommerce_sales/`

### Performance

- **Input:** ~15,000 rows
- **Output:** ~13,500-14,000 rows (after quality filters)
- **Processing Time:** ~10 seconds
- **Data Loss:** 5-10% (expected quality issues)

---

## 3. Gold Layer: Analytics Aggregation

### Purpose

Create business-intelligence-ready aggregated datasets for reporting and dashboards.

### Architecture Pattern: Star Schema

```
FACT TABLE: monthly_sales_by_category_region
├── Dimensions: order_year, order_month, order_quarter, category, region
├── Metrics: total_sales, total_profit, avg_discount, unique_customers
└── Partitioning: order_year, order_month

FACT TABLE: payment_analysis
├── Dimensions: payment_mode, payment_status, region
├── Metrics: transaction_count, total_value, profit_margin
└── Format: Parquet

FACT TABLE: top_products
├── Dimensions: category, sub_category, product_name
├── Metrics: units_sold, total_revenue, profit, avg_margin
└── Ranking: Within category
```

### Gold Table 1: Monthly Sales Aggregation

```sql
SELECT
    order_year, order_month, order_quarter,
    category, region,
    SUM(sales) as total_sales,
    SUM(net_sales) as total_net_sales,
    SUM(profit) as total_profit,
    COUNT(order_id) as total_orders,
    AVG(discount) as avg_discount_pct,
    AVG(profit_margin_pct) as avg_profit_margin_pct,
    COUNT(DISTINCT customer_name) as unique_customers,
    AVG(sales) as avg_order_value
FROM silver_layer
GROUP BY order_year, order_month, order_quarter, category, region
```

**Purpose:** Time-series and dimensional analysis

**Use Cases:**

- Monthly revenue trending
- Regional performance comparison
- Category-wise profitability
- Customer acquisition tracking

### Gold Table 2: Payment Analysis

```python
payment_df = df_silver.groupBy(
    "payment_mode", "payment_status", "region"
).agg(
    count("order_id").alias("transaction_count"),
    sum("sales").alias("total_transaction_value"),
    avg("sales").alias("avg_transaction_value")
)
```

**Insights:**

- Payment method effectiveness
- Regional payment preferences
- Transaction success rates
- Payment method profitability

### Gold Table 3: Product Performance

```python
products_df = df_silver.groupBy(
    "category", "sub_category", "product_name"
).agg(
    sum("quantity").alias("total_units_sold"),
    sum("sales").alias("total_revenue"),
    sum("profit").alias("total_profit"),
    dense_rank().over(
        Window.partitionBy("category")
               .orderBy(col("total_revenue").desc())
    ).alias("revenue_rank")
)
```

**Analysis:**

- Top/bottom performers per category
- Product profitability ranking
- Revenue contribution analysis

### Performance Characteristics

- **Aggregation Volume:** 15,000 → 3 tables with ~1,000 rows total
- **Processing Time:** ~5 seconds
- **Query Latency:** <100ms for typical queries
- **Storage Size:** ~5MB (compressed Parquet)

---

## 4. Data Quality Framework

### Quality Dimensions

#### 4.1 Completeness

- **Check:** Null counts per column
- **Action:** Impute with defaults or reject records
- **Threshold:** <5% nulls acceptable

#### 4.2 Uniqueness

- **Check:** Duplicate detection on primary keys
- **Action:** Remove exact duplicates
- **Threshold:** Zero duplicates expected

#### 4.3 Validity

- **Check:** Data type conformance, range validation
- **Action:** Filter invalid records
- **Examples:** Dates must parse, quantities ≥ 0

#### 4.4 Consistency

- **Check:** Business rule validation
- **Action:** Remove rule violations
- **Example:** Profit shouldn't exceed 50% loss margin

#### 4.5 Accuracy

- **Check:** Calculated field verification
- **Action:** Validate formulas (Net Sales = Sales - Discount)

### Quality Report Example

```
QUALITY METRICS REPORT
======================
Total Bronze Records: 15,000
Records after deduplication: 14,950 (0.33% removed)
Records after null handling: 14,950 (0% removed)
Records after date validation: 14,900 (0.33% removed)
Records after business rule validation: 14,800 (0.67% removed)

Final Silver Records: 14,800
Data Quality Score: 98.7%

Issues Identified:
- 150 records with invalid dates
- 50 records violating business rules
```

---

## 5. Incremental Processing (Future Enhancement)

### Current Approach

- Full refresh: Process all data each run
- Suitable for: Small-medium datasets

### Future: Incremental Load

```python
# Read control file for last processed timestamp
last_run_timestamp = read_control_file()

# Process only new data since last run
new_data = df_silver.filter(
    col("_silver_load_timestamp") > last_run_timestamp
)

# MERGE into gold tables
gold_table.alias("tgt").merge(
    new_data.alias("src"),
    "tgt.order_id = src.order_id"
).whenMatchedUpdateAll() \
 .whenNotMatchedInsertAll() \
 .execute()

# Update control file
write_control_file(current_timestamp())
```

**Benefits:**

- Process only changed data
- Reduced compute costs
- Lower pipeline duration
- Enable real-time analytics

---

## 6. Monitoring & Observability

### Pipeline Metrics

```python
# Log execution time
start_time = time.time()
# ... processing ...
execution_time = time.time() - start_time
logger.info(f"Pipeline completed in {execution_time}s")

# Log row counts
logger.info(f"Bronze: {bronze_count} rows")
logger.info(f"Silver: {silver_count} rows ({loss_pct}% filtered)")
logger.info(f"Gold: {gold_count} aggregations")

# Log KPIs
logger.info(f"Total Revenue: ₹{total_revenue:,.2f}")
logger.info(f"Profit Margin: {margin_pct:.2f}%")
```

### Alerts & Thresholds

| Alert         | Threshold       | Action                     |
| ------------- | --------------- | -------------------------- |
| Slow Pipeline | >60s            | Investigate performance    |
| Data Loss     | >15%            | Check data quality issues  |
| Null Values   | >10% per column | Review source data         |
| Duplicates    | >1%             | Assess deduplication rules |

---

## 7. Troubleshooting Guide

### Common Issues

#### Issue: "Input path does not exist"

```
Solution: Ensure CSV file exists at ./data/bronze/ecommerce_sales_raw.csv
Or run: create sample data first
```

#### Issue: "Date parse failed"

```
Solution: Check date format is DD-MM-YYYY
If different format, update: to_date(col("order_date"), "YOUR_FORMAT")
```

#### Issue: "Out of memory"

```
Solution:
1. Increase executor memory: spark.executor.memory 2g
2. Enable shuffle compression
3. Process smaller time windows
```

#### Issue: "Slow query performance"

```
Solution:
1. Use partitioned tables
2. Cache frequently accessed DataFrames
3. Use appropriate aggregation keys
4. Consider pre-aggregation in Gold layer
```

---

## 8. Best Practices

### Code Quality

✓ Use meaningful column aliases  
✓ Add logging at key checkpoints  
✓ Comment complex transformations  
✓ Validate all inputs

### Data Quality

✓ Implement checks at each layer  
✓ Document quality thresholds  
✓ Monitor data drift  
✓ Maintain data lineage

### Performance

✓ Partition large tables  
✓ Use appropriate file formats (Parquet, Delta)  
✓ Cache intermediate results  
✓ Avoid unnecessary shuffles

### Documentation

✓ Document business logic  
✓ Maintain data dictionary  
✓ Track schema changes  
✓ Record known issues

---

## Conclusion

This ETL pipeline demonstrates production-grade data engineering practices:

- **Reliable:** Multiple data quality checks
- **Scalable:** Efficient transformations with proper partitioning
- **Observable:** Comprehensive logging and metrics
- **Maintainable:** Well-documented code and processes

The pipeline successfully transforms raw transaction data into business-intelligence-ready analytics tables suitable for dashboards and reporting.
