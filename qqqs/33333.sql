WITH MergedMRs AS (
  SELECT
    DATE_TRUNC('MONTH', merged_at) AS merge_month,
    DATEDIFF('hour', created_at, merged_at) AS time_to_merge_hours
  FROM
    your_table_name  -- 実際のテーブル名に置き換えてください
  WHERE
    merged_at IS NOT NULL
)

SELECT
  merge_month,
  AVG(time_to_merge_hours) AS avg_time_to_merge_hours
FROM
  MergedMRs
GROUP BY
  merge_month
ORDER BY
  merge_month;
