-- One row per referenced file, total usage this year
drop table if exists wtcumfile;
create table wtcumfile(
 ffilename VARCHAR(255) PRIMARY KEY, -- filename, from hits.filename
 ffilecnt BIGINT,		     -- number of hits
 ffilebytes BIGINT		     -- total bytes
);
-- ffdir VARCHAR(255),
-- fffirst BIGINT,
-- fflast BIGINT,
-- ffnicnt BIGINT,
-- ffnibytes BIGIINT,
-- PRIMARY KEY(ffdir, ffilename)
