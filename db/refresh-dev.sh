#!/bin/sh
rm ./development.sqlite
cat schema_and_data.sql | sqlite3 development.sqlite
cat bird_presence_lists.sql | sqlite3 development.sqlite
cat nonbird_presence_lists.sql | sqlite3 development.sqlite
cat add_sighted_column.sql | sqlite3 development.sqlite
