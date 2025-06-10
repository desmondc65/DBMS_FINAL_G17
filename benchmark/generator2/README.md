# tpcds from DuckDB

tpcds extension from DuckDB can have sf=0.01,
which is smaller than original tools.

- step 1
```
python3 duck_extract.py
```
pip install package if it required.

- step 2
```
mysql -u username -p dbname < tpcds_data_dump.sql
```
create db if it doesn't exist.
