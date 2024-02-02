WITH monthly_completed_tasks AS (
  SELECT
    assignee,
    DATE_TRUNC('MONTH', completion_date) AS completion_month,
    COUNT(*) AS completed_tasks_count
  FROM
    task_table
  WHERE
    completion_date IS NOT NULL
  GROUP BY
    assignee,
    completion_month
),
ranked_assignees AS (
  SELECT
    completion_month,
    assignee,
    completed_tasks_count,
    ROW_NUMBER() OVER(PARTITION BY completion_month ORDER BY completed_tasks_count DESC) AS rank
  FROM
    monthly_completed_tasks
)
SELECT
  completion_month,
  assignee,
  completed_tasks_count
FROM
  ranked_assignees
WHERE
  rank <= 5
ORDER BY
  completion_month,
  rank;



SELECT
  DATE_TRUNC('MONTH', completion_date) AS completion_month,
  AVG(DATEDIFF(day, creation_date, completion_date)) AS average_completion_time
FROM
  task_table
WHERE
  completion_date IS NOT NULL
GROUP BY
  completion_month
ORDER BY
  completion_month;
