-- Super Webtrax, query words table, see wordlist.pl
-- One row per word, cumulative
-- thvv 09/09/11
DROP TABLE IF EXISTS wtyquerywords;
CREATE TABLE wtyquerywords (
 word VARCHAR(255) PRIMARY KEY, 
 wcount INT
);
