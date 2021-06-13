-- One row per referrer URL, total usage this year
-- Written 2006, Tom Van Vleck
-- 04/16/06
-- 06/20/06 make refcnt bigint
-- 06/20/06 added refwithquery
drop table if exists wtcumref;
create table wtcumref(
 refurl VARCHAR(255) PRIMARY KEY, -- referring URL, from hits.referrerurl
 refcnt BIGINT,			  -- number of hits
 refbytes BIGINT,		  -- total bytes
 refwithquery BIGINT		  -- count of hits that had nonblank query
);
-- reffirst BIGINT,
-- reflast BIGINT,
-- -- they are all NI
