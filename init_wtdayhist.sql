-- One row per log we processed.  Works best if these are a days worth of hits.
-- Updated by running a pass over hits and writing an SQL file with one INSERT, and then executing it
-- THVV 04/20/06
-- THVV 06/14/06 added graphic hits and bytes
drop table if exists wtdayhist;
create table wtdayhist(
 dbegtimebin BIGINT PRIMARY KEY, -- Unix timestamp of first hit
 dendtimebin BIGINT,		 -- Unix timestamp of last hit
 dhits BIGINT,			 -- count of hits 
 dbytes BIGINT,			 -- total bytes
 dvisits BIGINT,		 -- number of visits
 dhtmlpages BIGINT,		 -- number of HTML hits
 dgraphicpages BIGINT,		 -- number of graphic hits
 dtotalreckb BIGINT,	         -- number of bytes in logfile
 dtotalrecs  BIGINT,	 	 -- number of recs in logfile
 dhtmlfiles BIGINT,		 -- unique HTML files
 dhtmlbytes BIGINT,		 -- bytes in HTML files
 dgraphicbytes BIGINT,		 -- bytes in graphic files
 dnlinkhits BIGINT,		 -- hits on links
 dnlinkvisits BIGINT,		 -- visits from links
 dlinkbytes BIGINT,		 -- bytes from links
 dnsearches BIGINT,		 -- hits from search
 dnsearchvisits BIGINT,		 -- visits from search
 dsearchbytes BIGINT,		 -- bytes from search
 dnheadp BIGINT,		 -- number of head pages
 dhphits BIGINT,		 -- hits from head pages
 dhpbytes BIGINT,		 -- bytes from head pages
 dnohtmlvisits BIGINT,		 -- visits with no html
 dnohtmlvisitshits BIGINT,       -- hits from visits with no html
 dnohtmlbytes BIGINT,	         -- bytes from visits with no html
 dhtmlvisits BIGINT,		 -- visits with some html
 dindexhits BIGINT,		 -- hits from indexer
 dnindexvisits BIGINT,		 -- visits from indexer
 dindexbytes BIGINT,		 -- bytes from indexer
 dndomainstoday BIGINT,		 -- unique domains today
 dnewdomainstoday BIGINT,	 -- new domains today
 dhitsnovisit BIGINT,		 -- hits not in any visit
 ddomsnovisit BIGINT		 -- domains not in any visit
);
-- things we could use
--  non-indexer html, graphics, bytes
