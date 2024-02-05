WITH ranked_assignees AS (
  SELECT
    DATE_TRUNC('MONTH', creation_date) AS task_month,
    assignee,
    COUNT(*) AS tasks_count,
    ROW_NUMBER() OVER(PARTITION BY DATE_TRUNC('MONTH', creation_date) ORDER BY COUNT(*) DESC) AS rank
  FROM
    task_table
  GROUP BY
    task_month,
    assignee
),
combined_info AS (
  SELECT
    task_month,
    'Rank ' || rank::STRING AS rank_label,
    assignee || ' (' || tasks_count || ' tasks)' AS assignee_tasks_info
  FROM
    ranked_assignees
  WHERE
    rank <= 5
)

SELECT
  task_month,
  MAX(IFF(rank_label = 'Rank 1', assignee_tasks_info, NULL)) AS "Rank 1",
  MAX(IFF(rank_label = 'Rank 2', assignee_tasks_info, NULL)) AS "Rank 2",
  MAX(IFF(rank_label = 'Rank 3', assignee_tasks_info, NULL)) AS "Rank 3",
  MAX(IFF(rank_label = 'Rank 4', assignee_tasks_info, NULL)) AS "Rank 4",
  MAX(IFF(rank_label = 'Rank 5', assignee_tasks_info, NULL)) AS "Rank 5"
FROM
  combined_info
GROUP BY
  task_month
ORDER BY
  task_month;
