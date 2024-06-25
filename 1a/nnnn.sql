SELECT
  TO_CHAR(TO_DATE(columnA, 'YYYY-MM-DD'), 'YYYY/MM/DD') AS formatted_columnA,
  TO_CHAR(TO_DATE(columnB, 'YYYY-MM-DD'), 'FMMonth') AS formatted_columnB,
  columnC,
  columnD,
  -- その他のカラムもここに追加
FROM your_table;

SELECT TO_CHAR(TO_DATE(columnA, 'YYYY-MM-DD'), 'YYYY"年"MM"月"DD"日"') AS formatted_columnA
FROM your_table;


SELECT TO_CHAR(TO_NUMBER(columnB), 'FM9,999,999,999') AS formatted_columnB
FROM your_table;
