-- One row per referencing domain, total usage this year
drop table if exists wtdomhist;
create table wtdomhist(
 dhdom VARCHAR(255) PRIMARY KEY, -- hit domain, from hits.domain
 dhfirst DATE NOT NULL,	        -- first date this domain visited
 dhlast DATE NOT NULL,          -- most recent date this domain visited
 dhdays BIGINT,			-- number of days there was at least one visit
 dhvisits BIGINT,		-- number of visits
 dhhits BIGINT,			-- number of hits
 dhhtm BIGINT,			-- number of hits that were HTML
 dhgrf BIGINT,			-- number of hits that were graphic
 dhbytes BIGINT			-- total bytes
);

-- loading
-- INSERT INTO wtdomhist(dhdom, dhfirst, dhlast, dhdays, dhvisits, dhhits ,dhhtm, dhgrf, dhbytes) SELECT dddom, MIN(dddate), MAX(dddate), COUNT(*), SUM(ddvisits), SUM(ddhits), SUM(ddhtml), SUM(ddgraphic), SUM(ddbytes) FROM wtdomainday GROUP BY dddom;
