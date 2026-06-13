# Data Catalog — Gold Layer Sales Schema

> **Layer:** Gold (Curated / Business-Ready)
> **Purpose:** Supports sales reporting, customer analytics, and product performance analysis.
> **Last Updated:** June 2026

---

## Table of Contents

1. [gold_dim_customers](#1-gold_dim_customers)
2. [gold_dim_products](#2-gold_dim_products)
3. [gold.fact_sales](#3-goldfact_sales)
4. [Entity Relationship Summary](#4-entity-relationship-summary)

---

## 1. `gold_dim_customers`

**Type:** Dimension Table
**Description:** Contains one record per unique customer. Stores demographic and identity attributes used for customer segmentation, geographic analysis, and sales reporting by customer cohort.

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| `customer_key` | INT | **PK**, NOT NULL | Surrogate primary key. Auto-generated unique identifier for each customer record. Used as the join key in `gold.fact_sales`. |
| `customer_id` | VARCHAR | NOT NULL | Natural/source system identifier for the customer. Originates from the operational CRM or ERP system. |
| `customer_number` | VARCHAR | NOT NULL | Human-readable customer reference number. May be used in customer-facing communications. |
| `first_name` | VARCHAR | NULLABLE | Customer's first name. |
| `last_name` | VARCHAR | NULLABLE | Customer's last name. |
| `country` | VARCHAR | NULLABLE | Country of residence or billing address. |
| `create_date` | DATE | NULLABLE | The date the customer record was created in the system. Useful for cohort analysis, customer tenure calculations, and auditing. |
| `marital_status` | VARCHAR | NULLABLE | Customer's marital status (e.g., Single, Married). Used for demographic segmentation. |
| `gender` | VARCHAR | NULLABLE | Customer's gender. Used for demographic analysis and reporting. |
| `birthdate` | DATE | NULLABLE | Customer's date of birth. Can be used to derive age group or generational cohort. |

**Relationships:**
- `customer_key` → `gold.fact_sales.customer_key` (FK2) — One customer can have many sales transactions (1:N).

---

## 2. `gold_dim_products`

**Type:** Dimension Table
**Description:** Contains one record per unique product. Stores product hierarchy, cost, and lifecycle attributes used for product performance analysis, category reporting, and margin calculations.

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| `product_key` | INT | **PK**, NOT NULL | Surrogate primary key. Auto-generated unique identifier for each product record. Used as the join key in `gold.fact_sales`. |
| `product_number` | VARCHAR | NOT NULL | Natural/source system product code or SKU. Originates from the product catalog or ERP system. |
| `product_name` | VARCHAR | NOT NULL | Full descriptive name of the product. |
| `category_id` | INT | NULLABLE | Foreign key or identifier linking the product to its top-level category. |
| `category` | VARCHAR | NULLABLE | Top-level product category name (e.g., Electronics, Accessories). |
| `subcategory` | VARCHAR | NULLABLE | Sub-level classification within a category (e.g., Cables, Headphones within Electronics). |
| `maintenance` | VARCHAR / BOOLEAN | NULLABLE | Indicates whether the product requires or includes a maintenance plan. Interpretation may vary by source system. |
| `cost` | DECIMAL | NULLABLE | Unit cost of the product. Used alongside `price` from `fact_sales` to compute profit margin. |
| `product_line` | VARCHAR | NULLABLE | Product line or brand family the product belongs to (e.g., Premium, Budget). |
| `start_date` | DATE | NULLABLE | The date the product became active or was introduced. Useful for lifecycle and cohort analysis. |

**Relationships:**
- `product_key` → `gold.fact_sales.product_key` (FK1) — One product can appear in many sales transactions (1:N).

---

## 3. `gold.fact_sales`

**Type:** Fact Table
**Description:** Central transactional table capturing each sales order line. Connects customers and products to sales metrics. Supports revenue reporting, order fulfillment tracking, and profitability analysis. `sales_amount` is a derived/calculated column: `sales_amount = quantity × price`.

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| `order_number` | VARCHAR | NOT NULL | Unique identifier for a sales order. Multiple rows with the same `order_number` may exist if an order contains multiple products (order line level granularity). |
| `product_key` | INT | **FK1**, NOT NULL | Foreign key referencing `gold_dim_products.product_key`. Identifies which product was sold. |
| `customer_key` | INT | **FK2**, NOT NULL | Foreign key referencing `gold_dim_customers.customer_key`. Identifies which customer placed the order. |
| `order_date` | DATE | NULLABLE | The date the order was placed by the customer. |
| `shipping_date` | DATE | NULLABLE | The date the order was shipped. Used to calculate fulfillment lead time (`shipping_date − order_date`). |
| `due_date` | DATE | NULLABLE | The expected or promised delivery date. Used for SLA tracking and late delivery analysis. |
| `sales_amount` | DECIMAL | NULLABLE, **Derived** | Calculated sales revenue for the line item. **Formula:** `sales_amount = quantity × price`. Not stored independently — derived at query time or materialized. |
| `quantity` | INT | NOT NULL | Number of units sold for this line item. |
| `price` | DECIMAL | NOT NULL | Unit selling price at the time of the transaction. May differ from `cost` in `gold_dim_products` (cost vs. price). |

**Relationships:**
- `gold.fact_sales.customer_key` → `gold_dim_customers.customer_key` — Many-to-one (N:1). Each transaction belongs to one customer.
- `gold.fact_sales.product_key` → `gold_dim_products.product_key` — Many-to-one (N:1). Each transaction involves one product.

**Derived Metric Note:**

```
sales_amount = quantity × price
```

This is annotated directly in the schema diagram. When querying, always compute or verify this value rather than treating it as a source-of-truth stored field.

---

## 4. Entity Relationship Summary

```
gold_dim_customers          gold.fact_sales          gold_dim_products
──────────────────          ───────────────          ─────────────────
customer_key (PK) ──1────N── customer_key (FK2)
                             product_key  (FK1) ──N────1── product_key (PK)

Cardinality:
  gold_dim_customers  : gold.fact_sales  = 1 : Many
  gold_dim_products   : gold.fact_sales  = 1 : Many
  gold.fact_sales is the bridge (fact) table in a classic Star Schema.
```

**Schema Pattern:** Star Schema
- One central fact table (`gold.fact_sales`) joined to two dimension tables.
- Optimized for analytical queries (OLAP), aggregations, and BI tool consumption.

