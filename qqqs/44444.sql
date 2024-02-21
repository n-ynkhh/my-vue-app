WITH DateRange AS (
  SELECT
    DATE(created_at) AS analysis_date
  FROM
    your_table_name
  GROUP BY
    analysis_date
),

DailyMRStatus AS (
  SELECT
    d.analysis_date,
    COUNT(*) FILTER (WHERE m.merged_at IS NULL OR m.merged_at > d.analysis_date) AS unmerged_count,
    COUNT(*) FILTER (WHERE m.closed_at IS NULL OR m.closed_at > d.analysis_date) AS unclosed_count
  FROM
    DateRange d
    LEFT JOIN your_table_name m ON DATE(m.created_at) <= d.analysis_date
  GROUP BY
    d.analysis_date
)

SELECT
  analysis_date,
  unmerged_count,
  unclosed_count
FROM
  DailyMRStatus
ORDER BY
  analysis_date;
