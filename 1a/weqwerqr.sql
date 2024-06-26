SELECT 
  IFF(LENGTH(TO_CHAR(TO_DATE(columnB, 'YYYY-MM-DD'), 'MM')) = 2 AND LEFT(TO_CHAR(TO_DATE(columnB, 'YYYY-MM-DD'), 'MM'), 1) = '0',
      CONCAT(SUBSTRING(TO_CHAR(TO_DATE(columnB, 'YYYY-MM-DD'), 'MM'), 2, 1), '月'),
      CONCAT(TO_CHAR(TO_DATE(columnB, 'YYYY-MM-DD'), 'MM'), '月')) AS formatted_columnB
FROM 
  your_table;
