WITH SourceData AS (
    SELECT * FROM (
        VALUES
        (1, 'Value1_1', 'Value1_2'),
        (2, 'Value2_1', 'Value2_2'),
        (3, 'Value3_1', 'Value3_2'),
        (4, 'Value4_1', 'Value4_2'),
        (5, 'Value5_1', 'Value5_2')
    ) AS s(id, column1, column2)
)
MERGE INTO target_table AS t
USING SourceData AS s
ON t.id = s.id
WHEN MATCHED THEN
    UPDATE SET t.column1 = s.column1, t.column2 = s.column2
WHEN NOT MATCHED THEN
    INSERT (id, column1, column2)
    VALUES (s.id, s.column1, s.column2);
