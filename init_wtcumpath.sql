-- One row per internal link from one page to another, update script generated by pathsql.htmt
drop table if exists wtcumpath;
create table wtcumpath(
 -- both from and to have punctuation changed to underscore and _html removed
 cfrom VARCHAR(255) NOT NULL,   -- the thing hit, dirname/filename
 cto VARCHAR(255) NOT NULL,     -- the referrerurl, minus http://www.multicians.org
 ccnt BIGINT,			-- number of hits
 cbytes BIGINT,			-- total bytes
 PRIMARY KEY(cfrom, cto)
);
-- cfirst BIGINT,
-- clast BIGINT,
-- cnicnt BIGINT,
-- cnibytes BIGIINT,
