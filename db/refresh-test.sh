#!/bin/sh
rm ./test.sqlite
cat schema_and_data.sql | sqlite3 test.sqlite
cat presence_lists.sql | sqlite3 test.sqlite
