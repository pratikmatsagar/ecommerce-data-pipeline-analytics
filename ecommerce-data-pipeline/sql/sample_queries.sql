-- =============================================================================
-- SQL QUERIES FOR ECOMMERCE ANALYTICS
-- Sample queries for common business questions
-- Compatible with Delta Lake, Spark SQL, and traditional SQL engines
-- =============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- REVENUE ANALYSIS
-- ────────────────────────────────────────────────────────────────────────────

-- 1. Total Revenue by Month and Region
SELECT 
    order_year,
    order_month,
    region,
    SUM(total_sales) as monthly_revenue,
    SUM(total_net_sales) as net_revenue,
    SUM(total_profit) as profit,
    COUNT(*) as transaction_count,
    COUNT(DISTINCT customer_name) as unique_customers
FROM monthly_sales_by_category_region
GROUP BY order_year, order_month, region
ORDER BY order_year DESC, order_month DESC, monthly_revenue DESC;


-- 2. Top 10 Revenue-Generating Categories
SELECT 
    category,
    SUM(total_revenue) as total_revenue,
    SUM(total_units_sold) as units_sold,
    SUM(total_profit) as profit,
    ROUND(AVG(avg_profit_margin_pct), 2) as avg_margin_pct,
    COUNT(*) as product_count
FROM top_products
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. Year-over-Year Revenue Comparison
SELECT 
    order_year,
    SUM(total_sales) as yearly_revenue,
    COUNT(*) as transaction_count,
    ROUND(AVG(total_net_sales), 2) as avg_net_sales
FROM monthly_sales_by_category_region
GROUP BY order_year
ORDER BY order_year DESC;


-- ────────────────────────────────────────────────────────────────────────────
-- PRODUCT PERFORMANCE
-- ────────────────────────────────────────────────────────────────────────────

-- 4. Top 15 Products by Revenue
SELECT 
    product_name,
    category,
    sub_category,
    total_units_sold,
    ROUND(total_revenue, 2) as revenue,
    ROUND(total_profit, 2) as profit,
    ROUND(avg_profit_margin_pct, 2) as profit_margin_pct,
    order_count as sales_count
FROM top_products
ORDER BY total_revenue DESC
LIMIT 15;


-- 5. Bottom Performers (Low Profitability)
SELECT 
    product_name,
    category,
    total_revenue,
    total_profit,
    ROUND(avg_profit_margin_pct, 2) as margin_pct
FROM top_products
WHERE total_profit < 0  -- Loss-making products
ORDER BY total_profit ASC
LIMIT 10;


-- 6. Products by Category (Revenue Distribution)
SELECT 
    category,
    COUNT(*) as product_count,
    SUM(total_revenue) as category_revenue,
    ROUND(AVG(avg_profit_margin_pct), 2) as avg_margin_pct,
    MAX(total_revenue) as top_product_revenue
FROM top_products
GROUP BY category
ORDER BY category_revenue DESC;


-- ────────────────────────────────────────────────────────────────────────────
-- PAYMENT ANALYSIS
-- ────────────────────────────────────────────────────────────────────────────

-- 7. Payment Method Distribution
SELECT 
    payment_mode,
    SUM(transaction_count) as total_transactions,
    ROUND(SUM(total_transaction_value), 2) as total_value,
    ROUND(AVG(avg_transaction_value), 2) as avg_transaction_value,
    ROUND(SUM(total_profit), 2) as total_profit,
    ROUND(AVG(profit_margin_pct), 2) as avg_profit_margin_pct
FROM payment_analysis
GROUP BY payment_mode
ORDER BY total_value DESC;


-- 8. Payment Status Success Rate
SELECT 
    payment_status,
    COUNT(*) as status_count,
    SUM(transaction_count) as total_transactions,
    ROUND(
        SUM(transaction_count) * 100.0 / 
        (SELECT SUM(transaction_count) FROM payment_analysis),
        2
    ) as success_percentage
FROM payment_analysis
GROUP BY payment_status
ORDER BY total_transactions DESC;


-- 9. Payment Analysis by Region
SELECT 
    region,
    payment_mode,
    payment_status,
    transaction_count,
    ROUND(total_transaction_value, 2) as transaction_value,
    ROUND(avg_transaction_value, 2) as avg_value,
    ROUND(profit_margin_pct, 2) as margin_pct
FROM payment_analysis
ORDER BY region, transaction_value DESC;


-- ────────────────────────────────────────────────────────────────────────────
-- REGIONAL ANALYSIS
-- ────────────────────────────────────────────────────────────────────────────

-- 10. Regional Performance Summary
SELECT 
    region,
    SUM(total_sales) as region_revenue,
    SUM(total_profit) as region_profit,
    SUM(total_orders) as order_count,
    SUM(unique_customers) as customer_count,
    ROUND(SUM(total_profit) / SUM(total_sales) * 100, 2) as profit_margin_pct,
    ROUND(AVG(total_sales) / AVG(total_orders), 2) as avg_order_value
FROM monthly_sales_by_category_region
GROUP BY region
ORDER BY region_revenue DESC;


-- 11. Top Region by Category
SELECT 
    region,
    category,
    SUM(total_sales) as revenue,
    SUM(total_profit) as profit,
    SUM(total_orders) as orders,
    ROUND(SUM(total_sales) / SUM(total_orders), 2) as avg_order_value
FROM monthly_sales_by_category_region
WHERE order_year = YEAR(CURRENT_DATE)  -- Current year
GROUP BY region, category
ORDER BY region, revenue DESC;


-- ────────────────────────────────────────────────────────────────────────────
-- TREND ANALYSIS
-- ────────────────────────────────────────────────────────────────────────────

-- 12. Monthly Trend Analysis (Current Year)
SELECT 
    order_year,
    order_month,
    SUM(total_sales) as monthly_revenue,
    SUM(total_profit) as monthly_profit,
    SUM(total_orders) as order_count,
    ROUND(SUM(total_profit) / SUM(total_sales) * 100, 2) as margin_pct
FROM monthly_sales_by_category_region
WHERE order_year = YEAR(CURRENT_DATE)
GROUP BY order_year, order_month
ORDER BY order_month;


-- 13. Quarter Performance Comparison
SELECT 
    order_year,
    order_quarter,
    SUM(total_sales) as quarterly_revenue,
    SUM(total_profit) as quarterly_profit,
    SUM(total_orders) as order_count,
    SUM(unique_customers) as customer_count
FROM monthly_sales_by_category_region
GROUP BY order_year, order_quarter
ORDER BY order_year DESC, order_quarter DESC;


-- ────────────────────────────────────────────────────────────────────────────
-- CUSTOMER ANALYSIS
-- ────────────────────────────────────────────────────────────────────────────

-- 14. Customer Count by Region
SELECT 
    region,
    SUM(unique_customers) as total_unique_customers,
    COUNT(*) as transaction_periods  -- Number of time periods
FROM monthly_sales_by_category_region
GROUP BY region
ORDER BY total_unique_customers DESC;


-- 15. Average Customer Spending
SELECT 
    region,
    category,
    AVG(total_sales) as avg_category_sales,
    SUM(unique_customers) as customers,
    ROUND(SUM(total_sales) / SUM(unique_customers), 2) as revenue_per_customer
FROM monthly_sales_by_category_region
GROUP BY region, category
ORDER BY revenue_per_customer DESC
LIMIT 20;


-- ────────────────────────────────────────────────────────────────────────────
-- KPI DASHBOARD QUERIES
-- ────────────────────────────────────────────────────────────────────────────

-- 16. Executive Summary (All-Time Metrics)
SELECT 
    'Total Revenue' as metric,
    CAST(SUM(total_sales) as STRING) as value
FROM monthly_sales_by_category_region
UNION ALL
SELECT 
    'Total Profit' as metric,
    CAST(SUM(total_profit) as STRING) as value
FROM monthly_sales_by_category_region
UNION ALL
SELECT 
    'Total Orders' as metric,
    CAST(SUM(total_orders) as STRING) as value
FROM monthly_sales_by_category_region
UNION ALL
SELECT 
    'Unique Customers' as metric,
    CAST(SUM(unique_customers) as STRING) as value
FROM monthly_sales_by_category_region
UNION ALL
SELECT 
    'Avg Order Value' as metric,
    CAST(ROUND(SUM(total_sales) / SUM(total_orders), 2) as STRING) as value
FROM monthly_sales_by_category_region;


-- 17. Top 5 Performing Categories
SELECT 
    category,
    SUM(total_sales) as revenue,
    SUM(total_profit) as profit,
    RANK() OVER (ORDER BY SUM(total_sales) DESC) as rank
FROM monthly_sales_by_category_region
GROUP BY category
ORDER BY revenue DESC
LIMIT 5;


-- 18. Data Completeness Check
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT region) as regions,
    COUNT(DISTINCT category) as categories,
    MIN(order_year) as earliest_year,
    MAX(order_year) as latest_year,
    MIN(order_month) as earliest_month,
    MAX(order_month) as latest_month
FROM monthly_sales_by_category_region;


-- ────────────────────────────────────────────────────────────────────────────
-- DATA QUALITY QUERIES
-- ────────────────────────────────────────────────────────────────────────────

-- 19. Check for Negative Values (Data Quality)
SELECT 
    'Negative Sales' as issue,
    COUNT(*) as count
FROM monthly_sales_by_category_region
WHERE total_sales < 0
UNION ALL
SELECT 
    'Negative Profit' as issue,
    COUNT(*) as count
FROM monthly_sales_by_category_region
WHERE total_profit < 0
UNION ALL
SELECT 
    'Zero Orders' as issue,
    COUNT(*) as count
FROM monthly_sales_by_category_region
WHERE total_orders = 0;


-- 20. Summary Statistics
SELECT 
    'Monthly Sales Aggregations' as table_name,
    COUNT(*) as record_count,
    ROUND(AVG(total_sales), 2) as avg_sales,
    ROUND(MIN(total_sales), 2) as min_sales,
    ROUND(MAX(total_sales), 2) as max_sales
FROM monthly_sales_by_category_region
UNION ALL
SELECT 
    'Payment Analysis' as table_name,
    COUNT(*) as record_count,
    ROUND(AVG(total_transaction_value), 2) as avg_sales,
    ROUND(MIN(total_transaction_value), 2) as min_sales,
    ROUND(MAX(total_transaction_value), 2) as max_sales
FROM payment_analysis
UNION ALL
SELECT 
    'Top Products' as table_name,
    COUNT(*) as record_count,
    ROUND(AVG(total_revenue), 2) as avg_sales,
    ROUND(MIN(total_revenue), 2) as min_sales,
    ROUND(MAX(total_revenue), 2) as max_sales
FROM top_products;

