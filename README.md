# 📦 Olist E-Commerce Delivery & Retention Analysis

A SQL + Python analysis of **99K+ orders** across a 9-table relational database, investigating whether late delivery genuinely hurts customer satisfaction — and what's actually driving it — for the Olist Brazilian marketplace (2016–2018).

![SQL](https://img.shields.io/badge/SQL-SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-Pandas-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)

---

## 📌 Overview

This project analyzes Olist's order, delivery, and review data to answer one core question:

> **Is customer dissatisfaction actually caused by late delivery — and if so, is it a category problem or a seller problem?**

The analysis joins across 9 relational tables using SQL (orders, order items, sellers, products, reviews, customers), then validates the core hypothesis in Python before visualizing the result.

---

## 🚀 How to Run
| Step | Action |
|---|---|
| 1️⃣ | Download the dataset: [Olist Brazilian E-Commerce (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |
| 2️⃣ | Place all 9 CSVs into `/data` |
| 3️⃣ | Run `load_data.py` to build the SQLite database (`olist.db`) |
| 4️⃣ | Open `analysis.ipynb` in Jupyter/VS Code to run the full SQL + Python analysis |

> 💡 All SQL queries are also available standalone in `queries.sql`.

## 🖼️ Screenshot

### Review Score: Late vs On-Time Delivery
![Review Score Chart](./review_score_chart1.png)

---

## 🛠️ Tech Stack

- **Database:** SQLite (9-table relational schema, joined via foreign keys)
- **SQL:** Multi-table joins, `CASE` logic, `HAVING`, aggregate subqueries
- **Python:** pandas (query execution, aggregation), matplotlib (visualization)
- **Data Source:** [Olist Brazilian E-Commerce Public Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## 🔑 Key Findings

- 📉 **Late delivery destroys review scores** — 2.57/5 average for late orders vs. 4.29/5 for on-time, a 1.72-point gap
- ⏱️ **8.1% of all orders are late** (7,826 of 96,470 delivered orders)
- 🎯 **Lateness is seller-driven, not category-driven** — worst sellers run 30–50% late-delivery rates, while even the slowest product categories deliver ~9–10 days *early* on average
- 🔁 **Retention is the bigger risk** — only ~3% of customers (2,801 of 93,358) ever place a second order

---

## 🧮 Core SQL Queries

| Query | Purpose |
|---|---|
| Delay calculation | `julianday()` diff between actual and estimated delivery date |
| Late vs. on-time split | Overall order-level delivery performance |
| Review score comparison | Joins `orders` + `order_reviews` to test the core hypothesis |
| Seller ranking | Joins `order_items` to flag worst-performing sellers (min. 20 orders) |
| Repeat-purchase rate | Subquery grouping customers by order count |
| Category delay breakdown | Joins `products` to rule out category as the driver |

**Example — the core hypothesis test:**
```sql
SELECT 
    CASE 
        WHEN julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) > 0 
        THEN 'Late' ELSE 'On Time' 
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
```

---

## 🙌 Thank You

Thanks for checking this out! I built this to show how raw relational data can be turned into a tested, decision-ready finding — not just a chart.

If you're hiring for a **Data Analyst** role, I'd love to connect.

📩 **Let's connect:** [sushrutworks@gmail.com](mailto:sushrutworks@gmail.com)
🔗 **LinkedIn:** [@linkedin_Sushrut](https://www.linkedin.com/in/sushrutt/)
💻 **Portfolio:** [@sushrut_website](https://sushrut-portfolio.netlify.app/)
