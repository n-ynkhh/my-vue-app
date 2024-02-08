SELECT
  DATE_TRUNC('MONTH', check_date) AS month,
  COUNT(*) AS incomplete_tasks_count
FROM
  task_table,
  TABLE(GENERATOR(ROWCOUNT => DATEDIFF('MONTH', '起点となる日付', CURRENT_DATE()) + 1)) v
CROSS JOIN
  LATERAL (SELECT DATEADD('MONTH', SEQ4(), '起点となる日付') AS check_date)
WHERE
  completion_date IS NULL OR completion_date >= check_date
GROUP BY
  month
ORDER BY
  month;




SELECT
  DATE_TRUNC('WEEK', check_date) AS week,
  COUNT(*) AS incomplete_tasks_count
FROM
  task_table,
  TABLE(GENERATOR(ROWCOUNT => DATEDIFF('WEEK', '起点となる月曜日の日付', CURRENT_DATE()) + 1)) v
CROSS JOIN
  LATERAL (SELECT DATEADD('WEEK', SEQ4(), '起点となる月曜日の日付') AS check_date)
WHERE
  completion_date IS NULL OR completion_date >= check_date
GROUP BY
  week
ORDER BY
  week;



SELECT
  check_date::DATE AS day,
  COUNT(*) AS incomplete_tasks_count
FROM
  task_table,
  TABLE(GENERATOR(ROWCOUNT => DATEDIFF('DAY', '起点となる日付', CURRENT_DATE()) + 1)) v
CROSS JOIN
  LATERAL (SELECT DATEADD('DAY', SEQ4(), '起点となる日付') AS check_date)
WHERE
  completion_date IS NULL OR completion_date >= check_date
GROUP BY
  day
ORDER BY
  day;
