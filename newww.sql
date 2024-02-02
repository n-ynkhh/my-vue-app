WITH monthly_assignee_tasks AS (
  SELECT
    assignee,
    DATE_TRUNC('MONTH', creation_date) AS task_month,
    COUNT(*) AS tasks_count
  FROM
    task_table
  GROUP BY
    assignee,
    task_month
),
ranked_assignees AS (
  SELECT
    task_month,
    assignee,
    tasks_count,
    ROW_NUMBER() OVER(PARTITION BY task_month ORDER BY tasks_count DESC) AS rank
  FROM
    monthly_assignee_tasks
)
SELECT
  task_month,
  assignee,
  tasks_count,
  rank
FROM
  ranked_assignees
WHERE
  rank <= 5
ORDER BY
  task_month,
  rank;
