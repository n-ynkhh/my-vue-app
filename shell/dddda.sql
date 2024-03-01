SELECT
    DATE_TRUNC('MONTH', コミット日時) AS commit_month,
    プロジェクト名,
    COUNT(*) AS commit_count
FROM
    your_table_name
GROUP BY
    commit_month,
    プロジェクト名
ORDER BY
    commit_month ASC, プロジェクト名;


WITH monthly_commits AS (
    SELECT
        DATE_TRUNC('MONTH', コミット日時) AS commit_month,
        コミットしたユーザー名,
        COUNT(*) AS commit_count
    FROM
        your_table_name
    GROUP BY
        commit_month,
        コミットしたユーザー名
)
SELECT
    commit_month,
    コミットしたユーザー名,
    commit_count
FROM
    monthly_commits
QUALIFY
    ROW_NUMBER() OVER(PARTITION BY commit_month ORDER BY commit_count DESC) <= 5
ORDER BY
    commit_month ASC, commit_count DESC;



SELECT
    DATE_TRUNC('MONTH', コミット日時) AS commit_month,
    SUM(変更行数（追加）) AS lines_added,
    SUM(変更行数（削除）) AS lines_deleted
FROM
    your_table_name
GROUP BY
    commit_month
ORDER BY
    commit_month ASC;
