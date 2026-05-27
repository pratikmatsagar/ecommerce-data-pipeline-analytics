# Data Dictionary - E-Commerce Data Pipeline

Complete documentation of all data fields across Bronze, Silver, and Gold layers.

---

## Bronze Layer (Raw Data)

### Table: ecommerce_sales_raw

Raw transaction data from the source system. No transformations applied.

| Column           | Type    | Length | Nullable | Description                                   | Example       |
| ---------------- | ------- | ------ | -------- | --------------------------------------------- | ------------- |
| `order_id`       | String  | -      | NO       | Unique order identifier                       | ORD001        |
| `order_date`     | String  | 10     | NO       | Order date in DD-MM-YYYY format               | 15-01-2024    |
| `customer_name`  | String  | 100    | YES      | Customer name                                 | John Doe      |
| `region`         | String  | 20     | YES      | Geographic region (North/South/East/West)     | North         |
| `city`           | String  | 50     | YES      | City of delivery                              | Delhi         |
| `category`       | String  | 50     | YES      | Product category                              | Electronics   |
| `sub_category`   | String  | 50     | YES      | Product sub-category                          | Phones        |
| `product_name`   | String  | 100    | YES      | Product name                                  | iPhone 13 Pro |
| `quantity`       | Integer | -      | YES      | Number of units ordered                       | 2             |
| `unit_price`     | Double  | -      | YES      | Price per unit (₹)                            | 79999.00      |
| `discount`       | Double  | -      | YES      | Discount percentage (0-100)                   | 10.5          |
| `sales`          | Double  | -      | YES      | Total sale amount (₹) = quantity × unit_price | 159998.00     |
| `profit`         | Double  | -      | YES      | Profit amount (₹)                             | 15999.80      |
| `payment_mode`   | String  | 20     | YES      | Payment method                                | Credit Card   |
| `payment_status` | String  | 20     | YES      | Payment completion status                     | Completed     |

### Data Quality Metrics (Bronze)

- **Typical Volume:** 15,000 records
- **Expected Nulls:** 5-10% (scattered)
- **Duplicates:** 0.5-1% (data entry errors)
- **Valid Date %:** 98-99%

---

## Silver Layer (Cleaned Data)

### Table: ecommerce_sales (Cleaned & Standardized)

Transformed data with quality checks, standardization, and enrichment.

#### Original Columns (Transformed)

| Column              | Type    | Nullable | Transformation                      | Purpose                             |
| ------------------- | ------- | -------- | ----------------------------------- | ----------------------------------- |
| `order_id`          | String  | NO       | No change                           | Unique identifier for deduplication |
| `order_date`        | String  | NO       | Original (stored for reference)     | Source format preservation          |
| `order_date_parsed` | Date    | NO       | `to_date(order_date, "dd-MM-yyyy")` | Standardized date for analysis      |
| `customer_name`     | String  | NO       | Original                            | Customer identification             |
| `region`            | String  | NO       | Filled nulls → "Unknown"            | Regional segmentation               |
| `city`              | String  | NO       | Filled nulls → "Unknown"            | Geographic detail                   |
| `category`          | String  | NO       | Original                            | Product classification              |
| `sub_category`      | String  | NO       | Filled nulls → "Unknown"            | Product detail                      |
| `product_name`      | String  | NO       | Filled nulls → "Unknown"            | Product identification              |
| `quantity`          | Integer | NO       | Filled nulls → 0                    | Transaction volume                  |
| `unit_price`        | Double  | NO       | Filled nulls → 0.0                  | Unit cost                           |
| `discount`          | Double  | NO       | Filled nulls → 0.0                  | Discount applied                    |
| `sales`             | Double  | NO       | Filled nulls → 0.0                  | Total transaction value             |
| `profit`            | Double  | NO       | Filled nulls → 0.0                  | Profitability                       |
| `payment_mode`      | String  | NO       | Original                            | Payment method                      |
| `payment_status`    | String  | NO       | Original                            | Payment status                      |

#### Engineered Columns

| Column                   | Type      | Calculation                     | Purpose                | Example               |
| ------------------------ | --------- | ------------------------------- | ---------------------- | --------------------- |
| `order_year`             | Integer   | `year(order_date_parsed)`       | Year-based analysis    | 2024                  |
| `order_month`            | Integer   | `month(order_date_parsed)`      | Month-based analysis   | 1-12                  |
| `order_quarter`          | Integer   | `quarter(order_date_parsed)`    | Quarter-based analysis | 1-4                   |
| `order_day`              | Integer   | `dayofmonth(order_date_parsed)` | Day-of-month patterns  | 1-31                  |
| `net_sales`              | Double    | `sales × (1 - discount/100)`    | Revenue after discount | 143998.10             |
| `profit_margin_pct`      | Double    | `(profit / sales) × 100`        | Profitability %        | 10.00                 |
| `revenue_bucket`         | String    | IF/ELSE on sales value          | Revenue segmentation   | "High"/"Medium"/"Low" |
| `_silver_load_timestamp` | Timestamp | `current_timestamp()`           | Data lineage           | 2024-01-15 10:30:45   |
| `_silver_load_date`      | Date      | `order_date_parsed`             | Processing date        | 2024-01-15            |

### Data Quality Metrics (Silver)

- **Volume:** 13,500-14,000 records (5-10% filtered)
- **Nulls:** 0% (all handled)
- **Duplicates:** 0% (removed)
- **Valid Dates:** 100%
- **Quality Score:** 98%+

### Partitioning Strategy

- **Partition Columns:** `order_year`, `order_month`
- **Reason:** Enables efficient time-based queries
- **Example Path:** `silver/ecommerce_sales/order_year=2024/order_month=1/`

---

## Gold Layer (Analytics-Ready)

### Table 1: monthly_sales_by_category_region

Fact table with monthly sales aggregations by category and region.

#### Dimensions

| Column          | Type    | Description                  | Unique Values | Example     |
| --------------- | ------- | ---------------------------- | ------------- | ----------- |
| `order_year`    | Integer | Year of transaction          | 1             | 2024        |
| `order_month`   | Integer | Month of transaction (1-12)  | 12            | 1           |
| `order_quarter` | Integer | Quarter of transaction (1-4) | 4             | 1           |
| `category`      | String  | Product category             | 5-10          | Electronics |
| `region`        | String  | Geographic region            | 4             | North       |

#### Measures (Metrics)

| Column                  | Type      | Formula                       | Business Use           | Example             |
| ----------------------- | --------- | ----------------------------- | ---------------------- | ------------------- |
| `total_sales`           | Double    | SUM(sales)                    | Revenue tracking       | 1,500,000.00        |
| `total_net_sales`       | Double    | SUM(net_sales)                | Revenue after discount | 1,350,000.00        |
| `total_profit`          | Double    | SUM(profit)                   | Profitability          | 225,000.00          |
| `total_orders`          | Integer   | COUNT(order_id)               | Transaction volume     | 450                 |
| `avg_discount_pct`      | Double    | AVG(discount)                 | Average discount given | 5.2                 |
| `avg_profit_margin_pct` | Double    | AVG(profit_margin_pct)        | Average margin %       | 15.0                |
| `unique_customers`      | Integer   | COUNT(DISTINCT customer_name) | Customer count         | 120                 |
| `avg_order_value`       | Double    | AVG(sales)                    | Average transaction    | 3,333.33            |
| `profit_to_sales_ratio` | Double    | SUM(profit) / SUM(sales)      | Efficiency metric      | 0.15                |
| `_gold_load_timestamp`  | Timestamp | current_timestamp()           | Process time           | 2024-01-15 11:00:00 |

#### Aggregation Logic

```
GROUP BY: order_year, order_month, order_quarter, category, region
AGGREGATE: All numeric columns (SUM for totals, AVG for percentages, COUNT for counts)
```

#### Volume Estimates

- **Records:** 12-20 per month (5 categories × 4 regions = 20 cells)
- **Total Annual:** 240-480 records
- **File Size:** ~500KB annually

---

### Table 2: payment_analysis

Fact table analyzing payment methods and success rates.

#### Dimensions

| Column           | Type   | Description       | Unique Values                                    |
| ---------------- | ------ | ----------------- | ------------------------------------------------ |
| `payment_mode`   | String | Payment method    | 4-5 (Credit Card, Debit Card, UPI, Wallet, etc.) |
| `payment_status` | String | Payment outcome   | 2-3 (Completed, Pending, Failed)                 |
| `region`         | String | Geographic region | 4 (North, South, East, West)                     |

#### Measures

| Column                    | Type      | Formula                        | Purpose                    |
| ------------------------- | --------- | ------------------------------ | -------------------------- |
| `transaction_count`       | Integer   | COUNT(order_id)                | Volume of transactions     |
| `total_transaction_value` | Double    | SUM(sales)                     | Total value transacted     |
| `avg_transaction_value`   | Double    | AVG(sales)                     | Average transaction size   |
| `total_profit`            | Double    | SUM(profit)                    | Profit from payment method |
| `profit_margin_pct`       | Double    | SUM(profit) / SUM(sales) × 100 | Profitability              |
| `_gold_load_timestamp`    | Timestamp | current_timestamp()            | Process time               |

#### Volume Estimates

- **Records:** 20-30 (5 payment modes × 2-3 statuses × 4 regions)
- **File Size:** ~50KB

---

### Table 3: top_products

Fact table with product performance metrics.

#### Dimensions

| Column         | Type   | Description          | Unique Values |
| -------------- | ------ | -------------------- | ------------- |
| `category`     | String | Product category     | 5-10          |
| `sub_category` | String | Product sub-category | 15-20         |
| `product_name` | String | Product name         | 50-100        |

#### Measures

| Column                  | Type      | Formula                                                    | Purpose              |
| ----------------------- | --------- | ---------------------------------------------------------- | -------------------- |
| `total_units_sold`      | Integer   | SUM(quantity)                                              | Volume sold          |
| `total_revenue`         | Double    | SUM(sales)                                                 | Revenue generated    |
| `total_profit`          | Double    | SUM(profit)                                                | Profit contribution  |
| `order_count`           | Integer   | COUNT(order_id)                                            | Number of sales      |
| `avg_profit_margin_pct` | Double    | AVG(profit_margin_pct)                                     | Average margin       |
| `avg_order_value`       | Double    | AVG(sales)                                                 | Average transaction  |
| `revenue_rank`          | Integer   | DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue) | Rank within category |
| `_gold_load_timestamp`  | Timestamp | current_timestamp()                                        | Process time         |

#### Volume Estimates

- **Records:** 50-100 products
- **File Size:** ~100KB

---

## Revenue Bucket Definitions

Classification of transactions by sales value:

| Bucket     | Range             | Percentage of Transactions | Typical Use              |
| ---------- | ----------------- | -------------------------- | ------------------------ |
| **High**   | ≥ ₹100,000        | 5-10%                      | Premium segment analysis |
| **Medium** | ₹30,000 - ₹99,999 | 25-35%                     | Core business focus      |
| **Low**    | < ₹30,000         | 55-70%                     | Volume drivers           |

---

## Data Types Reference

| Type      | Size     | Range                    | Example                    |
| --------- | -------- | ------------------------ | -------------------------- |
| String    | Variable | -                        | "Electronics"              |
| Integer   | 4 bytes  | -2.1B to +2.1B           | 1500                       |
| Double    | 8 bytes  | IEEE 754                 | 1500.50                    |
| Date      | 4 bytes  | 1900-01-01 to 2100-12-31 | 2024-01-15                 |
| Timestamp | 8 bytes  | Microsecond precision    | 2024-01-15 10:30:45.123456 |

---

## Transformation Matrix

Shows data flow from Bronze → Silver → Gold:

```
BRONZE                  SILVER                  GOLD
─────────────────────────────────────────────────────────────
order_id        →→→     order_id        ─┐
order_date      →→→     order_date      │
                        order_date_parsed ───→ monthly_sales
customer_name   →→→     customer_name   ─┤
region          →→→     region          ├─→ payment_analysis
city            →→→     city            │
...             →→→     ...             ├─→ top_products
                        [engineered]    │
                        _silver_load_*  ─┘
```

---

## Common Queries by Use Case

### Revenue Analysis

```sql
SELECT order_year, order_month, SUM(total_sales)
FROM monthly_sales_by_category_region
GROUP BY order_year, order_month
```

### Product Performance

```sql
SELECT product_name, total_revenue, revenue_rank
FROM top_products
WHERE revenue_rank <= 10 AND category = 'Electronics'
```

### Payment Insights

```sql
SELECT payment_mode, transaction_count, profit_margin_pct
FROM payment_analysis
ORDER BY transaction_count DESC
```

---

## Metadata & Governance

### Data Ownership

- **Source:** E-commerce transaction systems
- **Owner:** Data Engineering Team
- **Steward:** Analytics Platform
- **Last Updated:** 2024-01-15

### Version History

- **v1.0** (2024-01-15): Initial release with 15k transactions
- **Schema Stability:** Expected to remain stable
- **Breaking Changes:** None anticipated

### SLA & Availability

- **Update Frequency:** Daily
- **Latency:** <1 hour from source
- **Availability:** 99.9%
- **Retention:** 2 years
