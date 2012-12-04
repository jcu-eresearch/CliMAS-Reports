#!/bin/sh
rm ./test.sqlite
cat schema_and_data.sql | sqlite3 test.sqlite
cat nonbird_presence_lists.sql | sqlite3 test.sqlite
cat add_sighted_column.sql | sqlite3 test.sqlite