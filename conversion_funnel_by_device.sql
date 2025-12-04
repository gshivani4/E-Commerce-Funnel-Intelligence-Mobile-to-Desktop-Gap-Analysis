CREATE DATABASE IF NOT EXISTS event_analytics;
USE event_analytics;

DROP TABLE IF EXISTS events_data;
CREATE TABLE events_data (
    event_id            VARCHAR(100),
    event_ts            VARCHAR(100),   -- kept as text for now
    user_id             VARCHAR(100),
    session_id          VARCHAR(100),
    event_type          VARCHAR(100),
    device_type         VARCHAR(100),
    platform            VARCHAR(100),
    country             VARCHAR(100),
    city                VARCHAR(100),
    session_duration    VARCHAR(100),   -- will cast in queries
    clicks_in_session   VARCHAR(100),   -- will cast in queries
    page_scroll_depth   VARCHAR(100),   -- will cast in queries
    price               VARCHAR(100)    -- will cast in queries
);

-- Query 1: Overall Funnel Drop-off
SELECT 
    event_type,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(*) AS total_events,
    ROUND(
        100 * COUNT(DISTINCT user_id) /
        (SELECT COUNT(DISTINCT user_id)
         FROM events_data
         WHERE event_type = 'page_view'),
        2
    ) AS conversion_pct
FROM events_data
WHERE event_type IN ('page_view','search','product_click','add_to_cart','checkout','purchase')
GROUP BY event_type
ORDER BY FIELD(event_type,
        'page_view','search','product_click','add_to_cart','checkout','purchase');
        
-- Query 2: Funnel by Device Type
SELECT 
    device_type,
    event_type,
    COUNT(DISTINCT user_id) AS unique_users
FROM events_data
WHERE event_type IN ('page_view','search','product_click','add_to_cart','checkout','purchase')
GROUP BY device_type, event_type
ORDER BY device_type,
    FIELD(event_type,'page_view','search','product_click','add_to_cart','checkout','purchase');
    
-- Query 3: Funnel by Platform
SELECT 
    platform,
    event_type,
    COUNT(DISTINCT user_id) AS unique_users,
    ROUND(
        100 * COUNT(DISTINCT user_id) /
        (SELECT COUNT(DISTINCT user_id)
         FROM events_data
         WHERE platform = e.platform
           AND event_type = 'page_view'),
        2
    ) AS conversion_pct
FROM events_data e
WHERE event_type IN ('page_view','search','product_click','add_to_cart','checkout','purchase')
GROUP BY platform, event_type
ORDER BY platform,
    FIELD(event_type,'page_view','search','product_click','add_to_cart','checkout','purchase');
    
-- Query 4: Drop-off Analysis (which step loses most users?)
WITH funnel_stats AS (
    SELECT 
        event_type,
        COUNT(DISTINCT user_id) AS users,
        FIELD(event_type,'page_view','search','product_click','add_to_cart','checkout','purchase') AS step_order
    FROM events_data
    WHERE event_type IN ('page_view','search','product_click','add_to_cart','checkout','purchase')
    GROUP BY event_type
)
SELECT 
    event_type,
    users,
    LAG(users) OVER (ORDER BY step_order) AS prev_step_users,
    LAG(users) OVER (ORDER BY step_order) - users AS drop_off,
    ROUND(
        100 *
        (LAG(users) OVER (ORDER BY step_order) - users) /
        LAG(users) OVER (ORDER BY step_order),
        2
    ) AS drop_off_pct
FROM funnel_stats
ORDER BY step_order;

-- PART 2: DEVICE PERFORMANCE
-- (casting VARCHAR → DECIMAL/INT inside queries)
-- =======================================================================

-- Query 5: Device Performance Summary
SELECT 
    device_type,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT session_id) AS total_sessions,
    ROUND(AVG(CAST(session_duration AS DECIMAL(10,2))), 2) AS avg_session_duration,
    ROUND(AVG(CAST(clicks_in_session AS DECIMAL(10,2))), 2) AS avg_clicks,
    ROUND(AVG(CAST(page_scroll_depth AS DECIMAL(10,3))), 3) AS avg_scroll_depth,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS users_who_purchased,
    ROUND(
        100 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END)
        / COUNT(DISTINCT user_id),
        2
    ) AS conversion_rate_pct
FROM events_data
GROUP BY device_type
ORDER BY conversion_rate_pct DESC;

-- Query 6: Revenue by Device
SELECT 
    device_type,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchasers,
    ROUND(SUM(CAST(CASE WHEN event_type = 'purchase' THEN price ELSE '0' END AS DECIMAL(10,2))), 2) AS total_revenue,
    ROUND(AVG(CAST(CASE WHEN event_type = 'purchase' THEN price ELSE NULL END AS DECIMAL(10,2))), 2) AS avg_order_value,
    ROUND(
        COUNT(*) / NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END),0),
        2
    ) AS events_per_purchase
FROM events_data
GROUP BY device_type
ORDER BY total_revenue DESC;

-- Query 7: Conversion Funnel by Device (event counts)
SELECT 
    device_type,
    SUM(event_type = 'page_view') AS page_views,
    SUM(event_type = 'search') AS searches,
    SUM(event_type = 'product_click') AS product_clicks,
    SUM(event_type = 'add_to_cart') AS add_to_cart,
    SUM(event_type = 'checkout') AS checkouts,
    SUM(event_type = 'purchase') AS purchases,
    ROUND(
        100 * SUM(event_type = 'purchase') /
        NULLIF(SUM(event_type = 'page_view'),0),
        2
    ) AS overall_conversion_pct
FROM events_data
GROUP BY device_type;

-- Query 8: Mobile vs Desktop Gap Analysis (performance vs best)
WITH device_metrics AS (
    SELECT 
        device_type,
        COUNT(DISTINCT user_id) AS users,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchasers,
        ROUND(
            100 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) /
            COUNT(DISTINCT user_id),
            2
        ) AS conversion_pct,
        ROUND(SUM(CAST(CASE WHEN event_type = 'purchase' THEN price ELSE '0' END AS DECIMAL(10,2))), 2) AS revenue
    FROM events_data
    GROUP BY device_type
)
SELECT 
    device_type,
    users,
    purchasers,
    conversion_pct,
    revenue,
    ROUND(
        100 * revenue / (SELECT SUM(revenue) FROM device_metrics),
        2
    ) AS revenue_contribution_pct,
    ROUND(
        100 * conversion_pct / (SELECT MAX(conversion_pct) FROM device_metrics),
        2
    ) AS performance_vs_best_pct
FROM device_metrics
ORDER BY conversion_pct DESC;

-- Query 9: Device Drop-off at Critical Steps
SELECT 
    device_type,
    SUM(event_type = 'add_to_cart') AS add_to_cart_events,
    SUM(event_type = 'checkout') AS checkout_events,
    SUM(event_type = 'purchase') AS purchase_events,
    ROUND(
        100 * SUM(event_type = 'checkout') /
        NULLIF(SUM(event_type = 'add_to_cart'),0),
        2
    ) AS cart_to_checkout_pct,
    ROUND(
        100 * SUM(event_type = 'purchase') /
        NULLIF(SUM(event_type = 'checkout'),0),
        2
    ) AS checkout_to_purchase_pct
FROM events_data
GROUP BY device_type
ORDER BY device_type;

-- =======================================================================
-- PART 3: DEVICE + PLATFORM MATRIX
-- =======================================================================

-- Query 10: Device-Platform Matrix
SELECT 
    device_type,
    platform,
    COUNT(DISTINCT user_id) AS users,
    ROUND(AVG(CAST(session_duration AS DECIMAL(10,2))), 1) AS avg_session_sec,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchasers,
    ROUND(
        100 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END)
        / COUNT(DISTINCT user_id),
        2
    ) AS conversion_pct,
    ROUND(SUM(CAST(CASE WHEN event_type = 'purchase' THEN price ELSE '0' END AS DECIMAL(10,2))), 0) AS revenue
FROM events_data
GROUP BY device_type, platform
ORDER BY conversion_pct DESC;

-- =======================================================================
-- PART 4: MASTER FACT TABLE (for Python / BI)
-- (keeps event_ts as text, no date parsing yet)
-- =======================================================================

-- Query 11: Master Fact Table
SELECT 
    event_id,
    event_ts,
    user_id,
    session_id,
    event_type,
    device_type,
    platform,
    country,
    city,
    session_duration,
    clicks_in_session,
    page_scroll_depth,
    price,
    CASE 
        WHEN event_type IN ('page_view','search','product_click') THEN 'Browse'
        WHEN event_type IN ('add_to_cart','checkout') THEN 'Checkout'
        WHEN event_type = 'purchase' THEN 'Purchase'
        ELSE 'Other'
    END AS funnel_stage,
    CASE 
        WHEN CAST(page_scroll_depth AS DECIMAL(10,3)) > 0.7 THEN 'High Engagement'
        WHEN CAST(page_scroll_depth AS DECIMAL(10,3)) > 0.4 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END AS engagement_level
FROM events_data
ORDER BY event_ts;