-- One row per query, total usage this year
-- Written 2006, Tom Van Vleck
-- 08/27/06
drop table if exists wtcumquery;
create table wtcumquery(
 query VARCHAR(255) PRIMARY KEY,  -- query, from hits.referrerquery
 querycnt BIGINT,	          -- number of hits
 querybytes BIGINT 		  -- total bytes
);
-- queryfirst BIGINT,
-- querylast BIGINT,
-- -- they are all NI
