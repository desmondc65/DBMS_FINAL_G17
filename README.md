# LLM-Based MySQL Query Rewriting

This repository contains the cleaned and processed execution times for various SQL queries across different query rewriting techniques. The data is stored in the file `execution_times_cleaned.csv`.

## File: `execution_times_cleaned.csv`

### Columns:

1. **Query**: The name of the SQL query.
2. **original_queries**: Execution time (in seconds) for the original query.
3. **static_rule_queries**: Execution time (in seconds) for the query rewritten using static rules.
4. **teacher_student_queries**: Execution time (in seconds) for the query rewritten using the teacher-student approach.
5. **in_context_learning_queries**: Execution time (in seconds) for the query rewritten using in-context learning.
6. **static_rule_queries_improvement(%)**: Percentage improvement in execution time for static rule queries compared to the original query.
7. **teacher_student_queries_improvement(%)**: Percentage improvement in execution time for teacher-student queries compared to the original query.
8. **in_context_learning_queries_improvement(%)**: Percentage improvement in execution time for in-context learning queries compared to the original query.

### Results:

| Query       | original_queries | static_rule_queries | teacher_student_queries | in_context_learning_queries | static_rule_queries_improvement(%) | teacher_student_queries_improvement(%) | in_context_learning_improvement(%) |
| ----------- | ---------------- | ------------------- | ----------------------- | --------------------------- | ---------------------------------- | -------------------------------------- | ---------------------------------- |
| query26.sql | 0.1059           | 0.253               | 0.2139                  | 0.0679                      | -138.9478                          | -101.9645                              | 35.8769                            |
| query3.sql  | 0.1283           | 0.1057              | 0.1189                  | 0.0268                      | 17.6509                            | 7.3371                                 | 79.1039                            |
| query76.sql | 0.1436           | 0.3248              | 0.2689                  | 0.0729                      | -126.29                            | -87.3                                  | 49.1962                            |
| query49.sql | 0.1477           | 0.2759              | 0.2708                  | 0.0759                      | -86.7133                           | -83.2751                               | 48.6305                            |
| query75.sql | 0.1505           | 0.2935              | 0.2612                  | 0.0789                      | -94.9471                           | -73.5425                               | 47.5996                            |
| query46.sql | 0.1546           | 0.4007              | 0.3535                  | 0.1144                      | -159.2609                          | -128.6861                              | 25.9737                            |
| query99.sql | 0.1653           | 0.1365              | 0.143                   | 0.0382                      | 17.4564                            | 13.5009                                | 76.9264                            |
| query27.sql | 0.1852           | 0.4719              | 0.4942                  | 0.1341                      | -154.7949                          | -166.855                               | 27.577                             |
| query77.sql | 0.2574           | 0.5972              | 0.5033                  | 0.1399                      | -131.9586                          | -95.4838                               | 45.6722                            |
| query11.sql | 0.3147           | 0.8763              | 0.7062                  | 0.2092                      | -178.4225                          | -124.3879                              | 33.5427                            |
| query6.sql  | 0.3772           | 0.6429              | 0.2614                  | 0.187                       | -70.424                            | 30.6946                                | 50.4348                            |
| query7.sql  | 0.6859           | 1.1378              | 1.0785                  | 0.3418                      | -65.8825                           | -57.2272                               | 50.1693                            |
| query13.sql | 1.3546           | 0.094               | 0.1553                  | 0.0242                      | 93.0596                            | 88.536                                 | 98.2137                            |

### Observations:

- **Positive Improvements**: Positive percentages in the improvement columns indicate faster execution times compared to the original query.
- **Negative Improvements**: Negative percentages indicate slower execution times compared to the original query.
- **Best Improvement**: Query `query13.sql` shows the highest improvement for `in_context_learning_queries` with a 98.2137% improvement.
- **Worst Performance**: Query `query46.sql` shows the worst performance for `static_rule_queries` with a -159.2609% degradation.
- In general in context learning performed the best.

### How to run:

```bash
# step 1: prepare database
cd benchmark/generator2/
python3 duck_extract.py
mysql -u username -p database < tpcds_data_dump.sql

# step 2: rewrite mysql queries using static rules, teacher student learning and in-context learning
cd SqlRewriter
python3 Pipeline.py

# step 3: run the generated queries and record the results
cd SqlRewriter
python3 SqlTimer.py
```
