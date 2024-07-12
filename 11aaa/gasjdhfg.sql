WITH TypeCounts AS (
    SELECT
        url,
        COUNT(DISTINCT type) AS type_count
    FROM
        your_table
    WHERE
        type IN ('a', 'b')
    GROUP BY
        url
)
SELECT
    t.url,
    CASE
        WHEN tc.type_count = 2 THEN 'both'
        WHEN tc.type_count = 1 THEN (SELECT type FROM your_table WHERE url = t.url LIMIT 1)
        ELSE 'none'
    END AS type_status
FROM
    your_table t
JOIN
    TypeCounts tc ON t.url = tc.url
GROUP BY
    t.url, tc.type_count
ORDER BY
    t.url;
