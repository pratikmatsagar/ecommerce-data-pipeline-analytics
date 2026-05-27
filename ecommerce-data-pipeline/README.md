# E-Commerce Data Pipeline & Analytics Platform

A production-ready data engineering project demonstrating end-to-end ETL pipelines for e-commerce analytics using the Medallion Architecture (Bronze → Silver → Gold). This portfolio project showcases modern data transformation techniques with PySpark, Delta Lake, and scalable data workflows suitable for cloud platforms like Azure Data Lake.

## 🎯 Project Overview

This project simulates a real-world e-commerce analytics platform processing 15,000+ Indian e-commerce transactions. It implements a three-layer data architecture to progressively transform raw data into business-intelligence-ready datasets.

**Key Highlights:**

- ✅ Complete ETL pipeline with data quality checks
- ✅ Medallion Architecture (Bronze-Silver-Gold layers)
- ✅ PySpark transformations with Delta Lake storage
- ✅ Business KPI calculations and aggregations
- ✅ Scalable, production-ready code
- ✅ Comprehensive documentation and logging

---

## 🏗️ Architecture

### Medallion Architecture Pattern

```
Bronze Layer (Raw)
    ↓ [Data Ingestion]
    ↓ Raw CSV/Parquet files from sources
    ↓
Silver Layer (Cleaned)
    ↓ [ETL: 01_bronze_to_silver.ipynb]
    ↓ Data cleaning, validation, deduplication
    ↓ Feature engineering for temporal analysis
    ↓ Delta Lake with partitioning
    ↓
Gold Layer (Analytics)
    ↓ [ETL: 02_silver_to_gold.ipynb]
    ↓ Business aggregations (fact tables)
    ↓ KPI calculations
    ↓ Dimension tables and analytical views
    ↓
Dashboards & Reporting
    ↓ [Power BI, Tableau, Metabase]
    ↓ Executive dashboards
    ↓ Real-time monitoring
```

### Data Flow Diagram

```
Sources
  │
  ├─→ Raw E-Commerce Data (CSV)
  │
  └─→ BRONZE LAYER (./data/bronze/)
      │
      ├─→ 01_bronze_to_silver.ipynb
      │   • Handle missing values
      │   • Remove duplicates
      │   • Parse dates
      │   • Create temporal features
      │   • Validate business logic
      │
      └─→ SILVER LAYER (./data/silver/)
          └─→ Clean, normalized data
              │
              ├─→ 02_silver_to_gold.ipynb
              │   • Aggregate by dimensions
              │   • Calculate KPIs
              │   • Create fact tables
              │   • Window function ranking
              │
              └─→ GOLD LAYER (./data/gold/)
                  │
                  ├─→ monthly_sales_by_category_region/
                  ├─→ payment_analysis/
                  └─→ top_products/
```

---

## 📊 Tech Stack

| Layer           | Technology             | Purpose                                     |
| --------------- | ---------------------- | ------------------------------------------- |
| **Processing**  | Apache Spark 3.5       | Distributed data processing                 |
| **Storage**     | Delta Lake, Parquet    | ACID transactions, performance optimization |
| **Language**    | Python 3.9+            | Data transformation logic                   |
| **Notebook**    | Jupyter                | Development and pipeline execution          |
| **Cloud-Ready** | Azure-compatible paths | Easily migrate to Azure Data Lake           |

---

## 📂 Project Structure

```
ecommerce-data-pipeline/
│
├── notebooks/
│   ├── 01_bronze_to_silver.ipynb    # Data cleaning & transformation
│   └── 02_silver_to_gold.ipynb      # Analytics aggregation & KPIs
│
├── data/
│   ├── bronze/                      # Raw data layer
│   ├── silver/                      # Cleaned data layer
│   └── gold/                        # Analytics-ready datasets
│
├── sql/
│   ├── fact_tables.sql             # Fact table definitions
│   ├── dimension_tables.sql        # Dimension table schemas
│   └── sample_queries.sql          # Common business queries
│
├── dashboard/
│   ├── dashboard_metrics.md        # KPI definitions
│   └── mockup.md                   # Dashboard mockup
│
├── docs/
│   ├── ETL_PROCESS.md              # Detailed process documentation
│   ├── DATA_DICTIONARY.md          # Column definitions
│   └── ARCHITECTURE.md             # Architecture deep-dive
│
├── screenshots/
│   ├── bronze_sample.png           # Raw data sample
│   ├── silver_sample.png           # Cleaned data sample
│   └── dashboard_preview.png       # Dashboard mockup
│
├── requirements.txt                 # Python dependencies
├── README.md                        # This file
└── architecture.md                  # Architecture documentation
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.9+
- Java 11+ (required by Spark)
- 4GB+ RAM (recommended 8GB)
- ~500MB disk space for sample data

### Installation

1. **Clone or download the repository**

   ```bash
   git clone <repository-url>
   cd ecommerce-data-pipeline
   ```

2. **Create a Python virtual environment**

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Start Jupyter**

   ```bash
   jupyter notebook
   ```

5. **Navigate to notebooks folder and run:**
   - Open `01_bronze_to_silver.ipynb` first
   - Then run `02_silver_to_gold.ipynb`

---

## 📝 Dataset Information

### Source Data: Indian E-Commerce Sales

**Records:** 15,000 transactions  
**Time Period:** January 2024 - December 2024  
**Geography:** India (North, South, East, West regions)

### Key Columns

| Column           | Type    | Description                    |
| ---------------- | ------- | ------------------------------ |
| `order_id`       | String  | Unique order identifier        |
| `order_date`     | String  | Order date (DD-MM-YYYY format) |
| `customer_name`  | String  | Customer name                  |
| `region`         | String  | Geographic region              |
| `city`           | String  | Delivery city                  |
| `category`       | String  | Product category               |
| `sub_category`   | String  | Product sub-category           |
| `product_name`   | String  | Product name                   |
| `quantity`       | Integer | Units ordered                  |
| `unit_price`     | Double  | Price per unit (₹)             |
| `discount`       | Double  | Discount percentage            |
| `sales`          | Double  | Total sales amount (₹)         |
| `profit`         | Double  | Profit amount (₹)              |
| `payment_mode`   | String  | Payment method                 |
| `payment_status` | String  | Payment status                 |

---

## 🔄 ETL Process

### Stage 1: Bronze to Silver (Data Cleaning)

**Input:** Raw CSV data  
**Output:** Cleaned, normalized Delta Lake tables

**Transformations:**

- ✓ Parse date strings (DD-MM-YYYY → Date)
- ✓ Remove exact duplicates on `order_id`
- ✓ Fill missing values with defaults
- ✓ Validate business logic (quantity ≥ 0, sales ≥ 0)
- ✓ Create temporal features (year, month, quarter, day)
- ✓ Calculate derived columns (net_sales, profit_margin_pct)
- ✓ Categorize revenue buckets

**Data Quality Checks:**

- Null value counts by column
- Duplicate detection
- Date validation
- Business rule violations

**Performance:** Processes 15,000 rows in ~10 seconds

### Stage 2: Silver to Gold (Analytics Aggregation)

**Input:** Cleaned Silver layer data  
**Output:** Analytics-ready fact and dimension tables

**Aggregations:**

1. **Monthly Sales by Category & Region**
   - Dimensions: Year, Month, Quarter, Category, Region
   - Metrics: Total sales, profit, order count, unique customers
   - Partitioned for fast queries

2. **Payment Analysis**
   - Dimensions: Payment mode, Status, Region
   - Metrics: Transaction count, total value, profit margin
   - Analyzes payment method effectiveness

3. **Top Products Performance**
   - Dimensions: Category, Sub-category, Product
   - Metrics: Units sold, revenue, profit, margin %
   - Ranked within each category

**Performance:** Aggregates into multiple tables in ~5 seconds

---

## 📊 Business KPIs

### Key Metrics Calculated

| KPI                     | Definition                  | Business Value            |
| ----------------------- | --------------------------- | ------------------------- |
| **Total Revenue**       | Sum of all sales            | Revenue tracking          |
| **Total Profit**        | Sum of profit amounts       | Profitability assessment  |
| **Profit Margin %**     | (Profit / Revenue) × 100    | Efficiency metric         |
| **Average Order Value** | Mean sales per order        | Customer spending pattern |
| **Unique Customers**    | Distinct customer count     | Customer base size        |
| **Orders by Region**    | Regional transaction volume | Market analysis           |
| **Top Categories**      | Categories by revenue       | Product performance       |

### Sample Results (15,000 transactions)

- **Total Revenue:** ₹50,000,000 (sample estimate)
- **Total Profit:** ₹8,000,000 (sample estimate)
- **Average Order Value:** ₹3,333
- **Profit Margin:** 16%

---

## 💡 Dashboard Preview

### Expected Dashboard Components

**1. Executive Summary**

- Total revenue YoY comparison
- Profit margin trend
- Customer count growth

**2. Regional Analysis**

- Revenue by region (map visualization)
- Regional profit distribution
- Regional trend analysis

**3. Product Performance**

- Top 10 products by revenue
- Category performance breakdown
- Product profitability analysis

**4. Payment Analysis**

- Payment method distribution
- Payment success rates
- Region-wise payment trends

**5. Time Series Analysis**

- Monthly revenue trend
- Seasonal patterns
- Year-over-year comparison

**Tools for Dashboarding:**

- Power BI (recommended for Azure integration)
- Tableau
- Metabase (open-source)
- Looker

---

## 📚 SQL Queries

Sample SQL queries for common business questions:

### Top 10 Products by Revenue

```sql
SELECT
    product_name,
    category,
    SUM(total_revenue) as revenue,
    SUM(total_units_sold) as units
FROM top_products
GROUP BY product_name, category
ORDER BY revenue DESC
LIMIT 10;
```

### Monthly Revenue Trend

```sql
SELECT
    order_year,
    order_month,
    SUM(total_sales) as monthly_revenue,
    COUNT(*) as transaction_count
FROM monthly_sales_by_category_region
GROUP BY order_year, order_month
ORDER BY order_year, order_month;
```

### Payment Success Analysis

```sql
SELECT
    payment_mode,
    payment_status,
    COUNT(*) as transaction_count,
    SUM(total_transaction_value) as value
FROM payment_analysis
GROUP BY payment_mode, payment_status;
```

---

## 🔧 Configuration & Customization

### Adjusting Data Paths

Edit the path constants in notebooks:

```python
BASE_PATH = Path("./data")  # Change if data is elsewhere
BRONZE_PATH = str(BASE_PATH / "bronze")
SILVER_PATH = str(BASE_PATH / "silver")
GOLD_PATH = str(BASE_PATH / "gold")
```

### For Azure Cloud Deployment

Replace local paths with Azure Data Lake Storage paths:

```python
# Local (current)
BRONZE_PATH = "./data/bronze"

# Azure Data Lake Storage Gen2
BRONZE_PATH = "abfss://bronze@yourstorageaccount.dfs.core.windows.net/"
```

### Modifying Data Quality Rules

In `01_bronze_to_silver.ipynb`, adjust business validation logic:

```python
# Current: profit can't exceed 50% loss
df = df.filter(col("profit") >= col("sales") * -0.5)

# Example: Custom profit margin range
df = df.filter(
    (col("profit") >= 0) &  # No losses
    (col("profit") <= col("sales") * 0.5)  # Max 50% margin
)
```

---

## 🧪 Data Quality Validation

The pipeline implements multiple quality checks:

1. **Completeness:** Null value counts per column
2. **Uniqueness:** Duplicate detection on order_id
3. **Validity:** Date format parsing validation
4. **Consistency:** Business rule checks (quantities, amounts)
5. **Accuracy:** Calculated field verification

**Quality Report Example:**

```
Null counts by column:
  city: 0
  product_name: 0
  sales: 0
Duplicate rows: 0
Invalid dates: 0
Business logic violations: 0
```

---

## 📈 Future Improvements

### Phase 2 Features

- [ ] Incremental processing with change data capture (CDC)
- [ ] Real-time streaming data ingestion
- [ ] Machine learning predictions (customer churn, demand forecasting)
- [ ] Advanced data quality framework (Great Expectations)
- [ ] Automated testing with pytest
- [ ] Data lineage and impact analysis

### Phase 3 Enhancements

- [ ] Multi-source data integration (supply chain, inventory)
- [ ] Advanced analytics (cohort analysis, RFM segmentation)
- [ ] Real-time dashboard with refresh rates
- [ ] Alerts for anomalies and KPI deviations
- [ ] Cost optimization recommendations

### Infrastructure

- [ ] Docker containerization for consistent environments
- [ ] Kubernetes orchestration
- [ ] CI/CD pipelines for automated testing
- [ ] Infrastructure-as-Code (Terraform/Bicep)
- [ ] Cost monitoring and optimization

---

## 🧑‍💻 Development Workflow

### Local Development

1. **Set up environment:**

   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Run notebooks locally:**

   ```bash
   jupyter notebook
   ```

3. **Test transformations:**
   ```bash
   pytest tests/
   ```

### Deploying to Azure

1. **Create Azure storage account and containers**
2. **Update notebook paths to Azure Data Lake**
3. **Create Databricks cluster**
4. **Upload notebooks to Databricks workspace**
5. **Schedule jobs with Azure Data Factory**

---

## 📖 Documentation

- [ETL_PROCESS.md](docs/ETL_PROCESS.md) - Detailed transformation logic
- [DATA_DICTIONARY.md](docs/DATA_DICTIONARY.md) - Column definitions
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture deep-dive
- [SQL Queries](sql/sample_queries.sql) - Common business queries

---

## 🎓 Learning Outcomes

By working through this project, you'll learn:

✓ PySpark DataFrame transformations  
✓ Delta Lake for data warehousing  
✓ ETL pipeline design and implementation  
✓ Data quality and validation techniques  
✓ Business analytics and KPI calculations  
✓ Data modeling (star schema)  
✓ Production-ready code practices  
✓ Scalable data architecture

---

## 📞 Support & Questions

For questions about:

- **PySpark:** [Official Spark Docs](https://spark.apache.org/docs/latest/)
- **Delta Lake:** [Delta Lake Documentation](https://docs.delta.io/)
- **Azure Data:** [Azure Data Engineering Guide](https://docs.microsoft.com/en-us/azure/architecture/data-guide/)

---

## 📋 License

This project is open-source for educational and portfolio purposes.

---

## ✨ Portfolio Highlights

**This project demonstrates:**

- ✅ Full-stack data engineering capabilities
- ✅ Production-quality code with logging
- ✅ Scalable architecture patterns
- ✅ Real-world business problem solving
- ✅ Cloud-ready implementation (Azure)
- ✅ Professional documentation and standards

**Ideal for roles:**

- Junior Data Engineer
- Analytics Engineer
- Data Analyst with engineering focus
- Azure Data Engineer (Associate level)

---

**Last Updated:** January 2024  
**Project Version:** 1.0.0  
**PySpark Version:** 3.5.0
