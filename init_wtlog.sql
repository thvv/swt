-- thvv One row per event
drop table if exists wtlog;
create table wtlog(
    logtime BIGINT PRIMARY KEY, -- thvv Unix timestamp of entry
    logtext VARCHAR(255)	-- thvv free text
);
