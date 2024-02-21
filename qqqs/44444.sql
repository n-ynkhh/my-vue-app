WITH AnalysisDate AS (
  SELECT
    MAX(created_at) AS target_date
  FROM
    your_table_name  -- 実際のテーブル名に置き換えてください
),
DailyMRStatus AS (
  SELECT
    DATE(created_at) AS created_date,
    COUNT(CASE WHEN merged_at IS NULL OR merged_at > DATE(created_at) THEN 1 END) AS unmerged_count,
    COUNT(CASE WHEN closed_at IS NULL OR closed_at > DATE(created_at) THEN 1 END) AS unclosed_count
  FROM
    your_table_name,
    AnalysisDate
  WHERE
    created_at <= AnalysisDate.target_date
  GROUP BY
    created_date
)

SELECT
  created_date,
  unmerged_count,
  unclosed_count
FROM
  DailyMRStatus
ORDER BY
  created_date;
