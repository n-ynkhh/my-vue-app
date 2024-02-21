SELECT
  MAX(GREATEST(created_at, updated_at)) AS latest_date,
  COUNT(*) AS unmerged_MR_count
FROM
  your_table_name  -- 実際のテーブル名に置き換えてください
WHERE
  merged_at IS NULL
  AND closed_at IS NULL
