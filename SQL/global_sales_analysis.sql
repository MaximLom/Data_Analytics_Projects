```sql
-- На початку я намагався розділити логіку на етапи CTE
WITH account_metr AS (
    SELECT  
        s.date AS event_date,
        sp.country,
        a.send_interval,
        a.is_verified,
        a.is_unsubscribed,
        COUNT(acs.account_id) AS account_cnt,
        0 AS sent_msg,
        0 AS open_msg,
        0 AS visit_msg
    FROM `data-analytics-mate.DA.account` a
    JOIN `data-analytics-mate.DA.account_session` acs
        ON a.id = acs.account_id
    JOIN `data-analytics-mate.DA.session` s
        ON acs.ga_session_id = s.ga_session_id
    JOIN `data-analytics-mate.DA.session_params` sp
        ON acs.ga_session_id = sp.ga_session_id
    GROUP BY s.date, sp.country, a.send_interval, a.is_verified, a.is_unsubscribed
),

email_metr AS (
    SELECT
        DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS event_date,
        sp.country,
        a.send_interval,
        a.is_verified,
        a.is_unsubscribed,
        0 AS account_cnt,
        COUNT(DISTINCT es.id_message) AS sent_msg,
        COUNT(DISTINCT eo.id_message) AS open_msg,
        COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM `data-analytics-mate.DA.email_sent` es
    JOIN `data-analytics-mate.DA.account_session` acs
        ON es.id_account = acs.account_id
    JOIN `data-analytics-mate.DA.session` s
        ON acs.ga_session_id = s.ga_session_id
    JOIN `data-analytics-mate.DA.session_params` sp
        ON acs.ga_session_id = sp.ga_session_id
    JOIN `data-analytics-mate.DA.account` a
        ON acs.account_id = a.id
    LEFT JOIN  `data-analytics-mate.DA.email_open` eo
        ON eo.id_message = es.id_message
    LEFT JOIN `data-analytics-mate.DA.email_visit` ev
        ON ev.id_message = es.id_message
    GROUP BY DATE_ADD(s.date, INTERVAL es.sent_date DAY), sp.country, a.send_interval, a.is_verified, a.is_unsubscribed
),

combined_metrics AS (
    SELECT * FROM account_metr
    UNION ALL
    SELECT * FROM email_metr
),

sum_metrics AS (
    SELECT
        event_date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        SUM(account_cnt) AS account_cnt,
        SUM(sent_msg) AS sent_msg,
        SUM(open_msg) AS open_msg,
        SUM(visit_msg) AS visit_msg
    FROM combined_metrics
    GROUP BY event_date, country, send_interval, is_verified, is_unsubscribed
),

total_metrics_by_country AS (
    SELECT
        event_date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        account_cnt,
        sent_msg,
        open_msg,
        visit_msg,
        SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt,
        SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt
    FROM sum_metrics
),

ranked_metrics AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
        DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
    FROM total_metrics_by_country
)

SELECT *
FROM ranked_metrics
WHERE rank_total_country_account_cnt <= 10 OR rank_total_country_sent_cnt <= 10
ORDER BY event_date;
