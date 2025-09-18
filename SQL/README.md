# E-commerce User Activity Analysis

## Project Description
This project involves a comprehensive analysis of user activity within an e-commerce database.  
The analysis covers key areas such as:

- Account creation  
- Email engagement (`sent`, `opened`, and `clicked`)  
- User verification status  
- Subscription status  

The goal is to facilitate comparisons between different countries, identify key markets, and perform user segmentation.

---

## SQL Query
The SQL query is designed to meet the following specific requirements:

- **CTE Usage**: Utilizes at least one Common Table Expression (CTE) to logically structure the query.  
- **Dimensions**: Metrics are calculated across a defined set of dimensions, including `date`, `country`, `send_interval`, `is_verified`, and `is_unsubscribed`.  
- **Metrics**: Computes several key metrics:  
  - `account_cnt`: The total number of new accounts created.  
  - `sent_msg`, `open_msg`, `visit_msg`: Metrics for email engagement.  
- **Country-Level Metrics & Ranks**:  
  - `total_country_account_cnt`, `total_country_sent_cnt`  
  - `rank_total_country_account_cnt`, `rank_total_country_sent_cnt`  
- **Data Combination**: The `UNION` operator is used to effectively combine both account and email metrics.  
- **Filtering**: The final output is filtered to display the **top 10 countries** based on `account_cnt` or `sent_msg`.

---

## Visualization
A Looker Studio dashboard has been created to provide a clear visual representation of the analysis, featuring:

- **Country-Level Metrics**: A table showing `account_cnt`, `total_country_sent_cnt`, `rank_total_country_account_cnt`, and `rank_total_country_sent_cnt`.  
- **Trends**: A time-series chart displaying the trend for the `sent_msg` metric over time.

---

## Deliverables
- A well-commented SQL query.  
- A screenshot of the Looker Studio visualization.  
- A link to the project documentation.  
