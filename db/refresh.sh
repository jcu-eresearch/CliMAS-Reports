#!/bin/sh
rm ./development.sqlite
cat schema_and_data.sql | sqlite3 development.sqlite
