# 📦 E-Commerce Revenue Gap Analysis

A deep-dive funnel and device-performance analysis on **50,000+ user events** revealing a **$27K/month mobile revenue gap** and uncovering **$50K+ monthly ROI opportunities** through conversion optimization, app promotion, and search improvement.

---

## 🎯 Project Overview

This project investigates why mobile users underperform despite high traffic share. Using Python, SQL, and Power BI, it uncovers funnel leaks, device gaps, and root causes behind poor mobile conversions.

**Key Outcome:**
📉 Mobile users = 45% of traffic but only 20% of revenue
📈 Identified actionable improvements = **$27K–$50K/month** revenue potential

---

## 🧩 Key Findings

### **1️⃣ Mobile Revenue Gap — $27K/month**

* Mobile CTR: 45% of users
* Mobile Revenue: 20%
* Desktop Conversion: **8%**
* Mobile Conversion: **2%** (6% gap)

### **2️⃣ Biggest Funnel Leak**

* **45% users drop between Search → Product Click**
* Poor search relevance + weak product listing experience

### **3️⃣ Checkout Abandonment (Critical)**

* Mobile abandonment: **60%**
* Desktop abandonment: **25%**

### **4️⃣ Mobile App Converts 8× Better**

* Mobile App Conversion: **8%**
* Mobile Web Conversion: **1%**
* Majority users unaware of app

---

## 🚀 Recommendations (With ROI)

| Recommendation           | Expected Gain   | ROI / Month | Priority    |
| ------------------------ | --------------- | ----------- | ----------- |
| Simplify Mobile Checkout | +90 conversions | **$27K**    | 🔴 High     |
| Promote Mobile App       | +36 conversions | **$18K**    | 🟡 Medium   |
| Search Optimization      | +150 clicks     | **$50K+**   | 🟢 Critical |

---

## 🛠️ Tech Stack

* **Python:** Pandas, NumPy, Matplotlib
* **SQL:** CTEs, Window Functions, Aggregations
* **Power BI:** DAX, KPI dashboards
* **Statistics:** Funnel metrics, hypothesis testing

---



## 🔍 Analysis Workflow

### **Phase 1 — Data Cleaning (Python)**

```python
df = pd.read_csv('events_data.csv')
df['event_ts'] = pd.to_datetime(df['event_ts'])
df = df.dropna(subset=['event_ts', 'user_id'])
df = df.drop_duplicates(subset=['event_id'])
```

### **Phase 2 — Funnel Analysis (SQL)**

```sql
SELECT event_type, COUNT(DISTINCT user_id) AS users
FROM events
WHERE event_type IN ('page_view','search','product_click','add_to_cart','checkout','purchase')
GROUP BY event_type;
```

### **Phase 3 — Device Segmentation**

Identify conversion gaps across:

* Desktop
* Mobile Web
* Mobile App

### **Phase 4 — Root Cause Analysis**

* Search leak
* Checkout friction
* Poor app visibility

### **Phase 5 — Dashboards (Power BI)**

* Funnel Drop-offs
* Device Performance Gap
* Revenue Leakage Metrics

---

## 📊 Key Metrics

| Metric                      | Value                        |
| --------------------------- | ---------------------------- |
| Events Analyzed             | 50,000+                      |
| Unique Users                | 12,000                       |
| Desktop Conversion          | 8%                           |
| Mobile Conversion           | 2%                           |
| Mobile Checkout Abandonment | 60%                          |
| Biggest Leak                | Search → Product Click (45%) |
| Opportunity                 | $27K–$50K/month              |

---

## 📈 **Dashboard**

* Waterfall visualization
* Stage-wise drop-off
* Device segmentation
* Traffic vs Revenue Pie Charts
* Conversion rates
* KPI: Mobile Revenue Gap

## 💡 Business Value

This project demonstrates:

* Strong analytical thinking
* Conversion optimization expertise
* Full-stack analytics (Python → SQL → BI)
* ROI-based decision making
* Executive-style storytelling

---

## 🧠 Learnings

* Always quantify impact
* Device-level funnels reveal deeper issues
* Trust issues and UX friction hit mobile hardest
* App users are most valuable
* Always convert analysis → action

---

## 📬 Contact

If you'd like to collaborate on analytics or BI projects, feel free to reach out!
