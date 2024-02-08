WITH date_range AS (
  SELECT
    MIN(DATE_TRUNC('MONTH', creation_date)) AS start_date,
    MAX(DATE_TRUNC('MONTH', creation_date)) AS end_date
  FROM
    task_table
),
monthly_dates AS (
  SELECT
    DATEADD('MONTH', SEQ4(), start_date) AS check_date
  FROM
    date_range,
    TABLE(GENERATOR(ROWCOUNT => 1 + DATEDIFF('MONTH', start_date, end_date))) v
)
SELECT
  check_date AS month,
  (SELECT COUNT(*) FROM task_table WHERE (completion_date IS NULL OR completion_date >= check_date)) AS incomplete_tasks_count
FROM
  monthly_dates
ORDER BY
  month;


WITH date_range AS (
  SELECT
    MIN(DATE_TRUNC('WEEK', creation_date)) AS start_date,
    MAX(DATE_TRUNC('WEEK', creation_date)) AS end_date
  FROM
    task_table
),
weekly_dates AS (
  SELECT
    DATEADD('WEEK', SEQ4(), start_date) AS check_date
  FROM
    date_range,
    TABLE(GENERATOR(ROWCOUNT => 1 + DATEDIFF('WEEK', start_date, end_date))) v
)
SELECT
  check_date AS week,
  (SELECT COUNT(*) FROM task_table WHERE (completion_date IS NULL OR completion_date >= check_date)) AS incomplete_tasks_count
FROM
  weekly_dates
ORDER BY
  week;


WITH date_range AS (
  SELECT
    MIN(creation_date) AS start_date,
    MAX(creation_date) AS end_date
  FROM
    task_table
),
daily_dates AS (
  SELECT
    DATEADD('DAY', SEQ4(), start_date) AS check_date
  FROM
    date_range,
    TABLE(GENERATOR(ROWCOUNT => 1 + DATEDIFF('DAY', start_date, end_date))) v
)
SELECT
  check_date AS day,
  (SELECT COUNT(*) FROM task_table WHERE (completion_date IS NULL OR completion_date >= check_date)) AS incomplete_tasks_count
FROM
  daily_dates
ORDER BY
  day;
