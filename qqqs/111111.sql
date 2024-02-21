WITH MonthlyMRCount AS (
  SELECT
    DATE_TRUNC('MONTH', created_At) AS month,
    project_name,
    COUNT(*) AS MR_count
  FROM
    your_table_name  -- ここに実際のテーブル名を入れてください
  GROUP BY
    DATE_TRUNC('MONTH', created_At),
    project_name
)

SELECT
  month,
  project_name,
  MR_count,
  SUM(MR_count) OVER(PARTITION BY month ORDER BY MR_count DESC) AS cumulative_MR_count
FROM
  MonthlyMRCount
ORDER BY
  month,
  project_name;
