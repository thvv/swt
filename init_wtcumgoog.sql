-- One row per referenced file, total hits by Google this year
drop table if exists wtcumgoog;
create table wtcumgoog(
 lgpath VARCHAR(255),		-- path
 lgcrawls BIGINT,		-- number of hits
 lgbytes BIGINT,		-- total bytes
 lgfirst BIGINT,		-- first systime
 lglast BIGINT,			-- last systime
 PRIMARY KEY(lgpath)
);
-- creating
-- insert into wtcumgoog(lgpath,lgcrawls,lgbytes,lgfirst,lglast) SELECT path,1,txsize,systime,systime FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0 AND hits.domain LIKE '%.googlebot.com' ON DUPLICATE KEY UPDATE lgcrawls=lgcrawls+1,lgbytes=lgbytes+hits.txsize,lglast=hits.systime
-- using
-- SELECT lgpath, FROM_UNIXTIME(lglast) FROM wtcumgoog ORDER BY lglast DESC LIMIT 3;
