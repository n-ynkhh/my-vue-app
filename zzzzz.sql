WITH recursive date_series AS (
  SELECT
    MIN(DATE_TRUNC('MONTH', creation_date)) AS check_date
  FROM
    task_table
  UNION ALL
  SELECT
    DATEADD('MONTH', 1, check_date)
  FROM
    date_series
  WHERE
    check_date < CURRENT_DATE()
)
SELECT
  check_date AS month,
  (SELECT COUNT(*) FROM task_table WHERE completion_date IS NULL OR completion_date > check_date) AS incomplete_tasks_count
FROM
  date_series
ORDER BY
  month;


WITH recursive date_series AS (
  SELECT
    MIN(DATE_TRUNC('WEEK', creation_date)) AS check_date
  FROM
    task_table
  UNION ALL
  SELECT
    DATEADD('WEEK', 1, check_date)
  FROM
    date_series
  WHERE
    check_date < CURRENT_DATE()
)
SELECT
  check_date AS week,
  (SELECT COUNT(*) FROM task_table WHERE completion_date IS NULL OR completion_date > check_date) AS incomplete_tasks_count
FROM
  date_series
ORDER BY
  week;

WITH recursive date_series AS (
  SELECT
    MIN(creation_date)::DATE AS check_date
  FROM
    task_table
  UNION ALL
  SELECT
    check_date + INTERVAL '1 day'
  FROM
    date_series
  WHERE
    check_date < CURRENT_DATE()
)
SELECT
  check_date AS day,
  (SELECT COUNT(*) FROM task_table WHERE completion_date IS NULL OR completion_date > check_date) AS incomplete_tasks_count
FROM
  date_series
ORDER BY
  day;

