    CASE 
        WHEN columnC IS NULL THEN NULL
        ELSE TO_CHAR(TO_NUMBER(columnC) * 100, 'FM9990.00') || '%'
    END AS formatted_columnC
