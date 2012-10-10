#!/bin/sh
rm ./test.sqlite
cat schema_and_data.sql | sqlite3 test.sqlite
