SELECT
    a.url,
    CASE
        WHEN b.url IS NOT NULL THEN 'has b'
        ELSE 'no b'
    END AS type_b_status
FROM
    (SELECT url FROM your_table WHERE type = 'a') a
LEFT JOIN
    (SELECT url FROM your_table WHERE type = 'b') b
ON
    a.url = b.url
ORDER BY
    a.url;
