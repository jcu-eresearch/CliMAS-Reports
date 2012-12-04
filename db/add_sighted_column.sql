PRAGMA foreign_keys=OFF;

BEGIN TRANSACTION;

alter table presence_lists
    add column occurrences INTEGER not null default 0
;

COMMIT;