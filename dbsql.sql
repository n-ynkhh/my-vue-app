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
),
combined_info AS (
  SELECT
    task_month,
    rank,
    assignee || ' (' || tasks_count || ' tasks)' AS assignee_tasks_info
  FROM
    ranked_assignees
  WHERE
    rank <= 5
)
SELECT
  task_month,
  rank,
  assignee_tasks_info
FROM
  combined_info
ORDER BY
  task_month,
  rank;
