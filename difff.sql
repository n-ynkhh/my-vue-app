WITH ranked_assignees AS (
  SELECT
    DATE_TRUNC('MONTH', creation_date) AS task_month,
    assignee,
    COUNT(*) AS tasks_count,
    ROW_NUMBER() OVER(PARTITION BY DATE_TRUNC('MONTH', creation_date) ORDER BY COUNT(*) DESC) AS rank
  FROM
    task_table
  WHERE
    creation_date IS NOT NULL
  GROUP BY
    task_month,
    assignee
),
combined_info AS (
  SELECT
    rank,
    task_month,
    assignee || ' (' || tasks_count || ' tasks)' AS assignee_tasks_info
  FROM
    ranked_assignees
  WHERE
    rank <= 5
)

SELECT 'Rank 1' AS Rank, ARRAY_AGG(assignee_tasks_info) WITHIN GROUP (ORDER BY task_month) AS Monthly_Info FROM combined_info WHERE rank = 1
UNION ALL
SELECT 'Rank 2', ARRAY_AGG(assignee_tasks_info) WITHIN GROUP (ORDER BY task_month) FROM combined_info WHERE rank = 2
UNION ALL
SELECT 'Rank 3', ARRAY_AGG(assignee_tasks_info) WITHIN GROUP (ORDER BY task_month) FROM combined_info WHERE rank = 3
UNION ALL
SELECT 'Rank 4', ARRAY_AGG(assignee_tasks_info) WITHIN GROUP (ORDER BY task_month) FROM combined_info WHERE rank = 4
UNION ALL
SELECT 'Rank 5', ARRAY_AGG(assignee_tasks_info) WITHIN GROUP (ORDER BY task_month) FROM combined_info WHERE rank = 5
