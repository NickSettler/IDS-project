# Indexes notes

## Script

```sql
EXPLAIN PLAN FOR
SELECT s.suite_number, st.capacity, COUNT(r.client_passport) AS reservation_quantity
FROM reservation r
         JOIN suite s on r.suite_number = s.suite_number
         JOIN suite_type st on s.suite_type_id = st.id
GROUP BY s.suite_number, st.capacity;

CREATE INDEX suite_number ON reservation (suite_number);
CREATE INDEX suite_type_id ON suite (suite_type_id);

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT s.suite_number, st.capacity, COUNT(r.client_passport) AS reservation_quantity
FROM reservation r
         JOIN suite s on r.suite_number = s.suite_number
         JOIN suite_type st on s.suite_type_id = st.id
GROUP BY s.suite_number, st.capacity;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);
```

## Results

### Without indexes

```text
+------------------------------------------------------------------------------------+
|PLAN_TABLE_OUTPUT                                                                   |
+------------------------------------------------------------------------------------+
|Plan hash value: 221240364                                                          |
|                                                                                    |
|------------------------------------------------------------------------------------|
|| Id  | Operation            | Name        | Rows  | Bytes | Cost (%CPU)| Time     ||
|------------------------------------------------------------------------------------|
||   0 | SELECT STATEMENT     |             |    33 |  2145 |    10  (10)| 00:00:01 ||
||   1 |  HASH GROUP BY       |             |    33 |  2145 |    10  (10)| 00:00:01 ||
||*  2 |   HASH JOIN          |             |    33 |  2145 |     9   (0)| 00:00:01 ||
||*  3 |    HASH JOIN         |             |    33 |  1287 |     6   (0)| 00:00:01 ||
||*  4 |     TABLE ACCESS FULL| RESERVATION |    33 |   429 |     3   (0)| 00:00:01 ||
||   5 |     TABLE ACCESS FULL| SUITE       |   140 |  3640 |     3   (0)| 00:00:01 ||
||   6 |    TABLE ACCESS FULL | SUITE_TYPE  |     5 |   130 |     3   (0)| 00:00:01 ||
|------------------------------------------------------------------------------------|
|                                                                                    |
|Predicate Information (identified by operation id):                                 |
|---------------------------------------------------                                 |
|                                                                                    |
|   2 - access("S"."SUITE_TYPE_ID"="ST"."ID")                                        |
|   3 - access("R"."SUITE_NUMBER"="S"."SUITE_NUMBER")                                |
|   4 - filter("R"."SUITE_NUMBER">1000 AND "R"."SUITE_NUMBER"<9999)                  |
|                                                                                    |
|Note                                                                                |
|-----                                                                               |
|   - dynamic statistics used: dynamic sampling (level=2)                            |
|   - this is an adaptive plan                                                       |
+------------------------------------------------------------------------------------+
```

### With indexes

```text
+------------------------------------------------------------------------------------------------+
|PLAN_TABLE_OUTPUT                                                                               |
+------------------------------------------------------------------------------------------------+
|Plan hash value: 288985016                                                                      |
|                                                                                                |
|------------------------------------------------------------------------------------------------|
|| Id  | Operation                      | Name          | Rows  | Bytes | Cost (%CPU)| Time     ||
|------------------------------------------------------------------------------------------------|
||   0 | SELECT STATEMENT               |               |    33 |  2145 |     7  (29)| 00:00:01 ||
||   1 |  HASH GROUP BY                 |               |    33 |  2145 |     7  (29)| 00:00:01 ||
||   2 |   NESTED LOOPS                 |               |    33 |  2145 |     6  (17)| 00:00:01 ||
||   3 |    MERGE JOIN                  |               |   140 |  7280 |     6  (17)| 00:00:01 ||
||   4 |     TABLE ACCESS BY INDEX ROWID| SUITE         |   140 |  3640 |     2   (0)| 00:00:01 ||
||   5 |      INDEX FULL SCAN           | SUITE_TYPE_ID |   140 |       |     1   (0)| 00:00:01 ||
||*  6 |     SORT JOIN                  |               |     5 |   130 |     4  (25)| 00:00:01 ||
||   7 |      TABLE ACCESS FULL         | SUITE_TYPE    |     5 |   130 |     3   (0)| 00:00:01 ||
||*  8 |    INDEX RANGE SCAN            | SUITE_NUMBER  |     1 |    13 |     0   (0)| 00:00:01 ||
|------------------------------------------------------------------------------------------------|
|                                                                                                |
|Predicate Information (identified by operation id):                                             |
|---------------------------------------------------                                             |
|                                                                                                |
|   6 - access("S"."SUITE_TYPE_ID"="ST"."ID")                                                    |
|       filter("S"."SUITE_TYPE_ID"="ST"."ID")                                                    |
|   8 - access("R"."SUITE_NUMBER"="S"."SUITE_NUMBER")                                            |
|       filter("R"."SUITE_NUMBER">1000 AND "R"."SUITE_NUMBER"<9999)                              |
|                                                                                                |
|Note                                                                                            |
|-----                                                                                           |
|   - dynamic statistics used: dynamic sampling (level=2)                                        |
+------------------------------------------------------------------------------------------------+
```

## Conclusion

In this [SQL script](#script), the two indexes created on the `reservation` and `suite` tables can help to improve the
performance of the `SELECT` statement by speeding up the execution of the join operations involved.

The index `suite_number` created on the `reservation` table can be used to speed up the join operation with the `suite`
table on the `suite_number` column. This is because the index allows for faster lookup of the rows in the `reservation`
table that match the `suite_number` values in the suite table. Without the index, the database would have to scan the
entire `reservation` table to find the matching rows, which could be slow for large tables.

Similarly, the index `suite_type_id` created on the `suite` table can be used to speed up the join operation with the
`suite_type` table on the `id` column. This is because the index allows for faster lookup of the rows in the `suite`
entire `suite` table to find the matching rows, which could be slow for large tables.

By using these indexes, the join operations involved in the `SELECT` statement can be performed faster, resulting in a
faster overall query execution time. The `EXPLAIN PLAN` statement can be used to analyze the execution plan of the query
and determine whether the indexes are being used effectively. The `DBMS_XPLAN.DISPLAY` function can be used to display
the execution plan details and identify any performance bottlenecks in the query execution.

The second output shows that using appropriate indexes can significantly improve the performance of a query. Compared to
the first output, the second output has a lower cost and uses less CPU time to execute the same query. The use of an
index range scan on the `SUITE_NUMBER` column and an index full scan on the `SUITE_TYPE_ID` column have reduced the
number of rows accessed, resulting in a faster query execution time. 