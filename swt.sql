-- Schema for Super webtrax
-- 2006-2021, Tom Van Vleck
-- THVV 2006-04-20 1.0
-- THVV 2006-06-10 1.1 add wtvsources and wtvclasses for striping
-- THVV 2006-06-20 1.2 split user stuff into swt-user.sql
-- THVV 2006-07-18 1.3 add wtreferrercolor
-- THVV 2006-08-09 1.4 move swt-user.sh values into sql
-- THVV 2006-08-10 1.5 add swtiches to enable reports
-- THVV 2006-08-14 1.6 add options for which pie charts are in short
-- THVV 2006-08-14 1.7 add options for eventlog
-- THVV 2006-08-18 1.8 add wtqueries table
-- THVV 2006-08-25 1.81 change webtraxhead.htmt to heading.htmt
-- THVV 2006-08-26 2.0 add printvisitdetail, visitdata, and table update queries
-- THVV 2006-08-27 2.1 add year query report
-- THVV 2006-08-29 2.2 add attacks report
-- THVV 2006-08-30 2.21 fix total in year_query
-- THVV 2006-09-01 2.22 retcode report good percent
-- THVV 2006-09-08 2.3 Suppress uninteresting 404s
-- THVV 2006-09-17 2.4 Don't put 404s in wtcumpage; put watched filenames in color; fix headings 
-- THVV 2006-09-17 2.4 don't count on expandfile in path; add more filenames to hacks
-- THVV 2006-09-18 2.5 change hacks check to join
-- THVV 2006-09-21 2.6 Add wtglobvar table, minor fix to ref spam detector
-- THVV 2006-10-08 2.7 Update wtindexers and wthackfilenames
-- THVV 2006-10-13 2.71 Update wthackfilenames, add dirname to attacks report
-- THVV 2006-10-19 2.8 Add comparison to previous days to month summary
-- THVV 2006-11-10 2.9 Add list of boring files
-- THVV 2006-11-20 3.0 Remove wtcumdom and wtdomaindays, add wtdomhist
-- THVV 2006-11-21 3.1 Add DLSV and visits to year_domain, add DSPV to domain
-- THVV 2006-11-28 3.2 Make paths report parametric in site name
-- THVV 2006-11-29 3.3 Add wtcumgoog table and queries on it, google crawl report
-- THVV 2006-12-19 3.4 Add query for cleaning up referrer spam
-- THVV 2006-12-21 3.5 Fix bug, googlebot was not being recognized if it had [us] suffix
-- THVV 2006-12-27 3.6 Use path instead of filename in many places
-- THVV 2006-12-29 3.7 Add wthackfiletypes to catch more attacks
-- THVV 2007-01-05 3.8 Use hitslices in visitdata
-- THVV 2007-01-13 3.81 Declare wtpclasses with larger class list
-- THVV 2007-01-13 3.9 Add pie chart on continent
-- THVV 2007-01-18 3.91 Add subsubtitle for details report
-- THVV 2007-01-31 3.92 Remove .um domain, obsolete
-- THVV 2007-02-19 4.0 Change year referrer query to show just the domain
-- THVV 2007-02-19 4.01 Add documentation of configurable tables
-- THVV 2007-04-10 4.02 Add php3 to hackfiletypes
-- THVV 2007-05-14 4.03 Update country codes
-- THVV 2007-06-09 4.04 recognize Google hits even though location suffix has more data
-- THVV 2007-06-09 4.1 add showanyway table to show graphics if referrer and filename match
-- THVV 2007-07-12 4.11 add heritrix to indexers
-- THVV 2007-07-26 4.12 add "bot" to indexers and remove redundant
-- THVV 2007-07-27 4.2 Change wtindexers to hold multiple browser types
-- THVV 2007-09-12 4.3 Fix bug in year_query
-- THVV 2007-09-15 4.31 Fix bug in total number of queries, was counting blank, off by one
-- THVV 2007-09-15 4.31 Fix bug in heading line of year referrer report, needed where clause
-- THVV 2007-09-18 4.4 monthly bandwidth and quota
-- THVV 2007-09-19 4.5 recognize webmail; don't put blank domain into wtdomhist
-- THVV 2007-11-23 4.51 add more robots to wtindexers
-- THVV 2007-12-05 4.52 add referrer spam transform
-- THVV 2007-12-27 4.6 add authsess and authid report
-- THVV 2008-05-01 4.61 add aspx to hackfiletypes
-- THVV 2008-08-14 4.7 expand wtsuffixclass for short and long
-- THVV 2008-09-18 4.71 add wtglobalvalue parameter visitdata_refspamthresh
-- THVV 2008-10-28 4.72 add pieappletextra parameter to pie chart
-- THVV 2008-10-30 4.721 update wtindexers
-- THVV 2009-03-20 4.8 add rpt_attacks overuse report
-- THVV 2009-03-23 4.81 correct qnbrow to count simplified browser names
-- THVV 2009-03-27 4.82 correct rpt_browser query to not mix platforms
-- THVV 2009-03-29 4.9 add visits by city and repeated hits reports
-- THVV 2009-07-01 4.91 add websense to wtrobotdomains
-- THVV 2009-07-11 4.92 add netcraft to wtindexers
-- THVV 2009-09-08 4.93 add amazonaws to wtrobotdomains
-- THVV 2009-09-25 4.94 add scoutjet to wtindexers, more tweaks
-- THVV 2010-02-12 4.95 suppress uninteresting illegal referrers
-- THVV 2010-06-14 4.96 suppress hack files from 404 report
-- THVV 2010-07-18 4.961 add aspx to hackfiletypes
-- THVV 2010-08-07 4.962 added more gTLDs to countrynames
-- THVV 2010-10-29 4.963 transform THVV and POS4 IP
-- THVV 2010-10-29 4.97 make wthackfile use a regexp and detect phpMyAdmin attacks
-- THVV 2010-10-29 5.0 add byyear
-- THVV 2010-12-12 5.1 do pie charts in Javascript instead of Java
-- THVV 2011-04-07 5.101 new POS4 IP
-- THVV 2011-05-05 5.102 new THVV IP
-- THVV 2011-06-09 5.103 add ezooms to wtindexers and piecanvas.js to boring
-- THVV 2011-06-15 5.104 add 008 to wtindexers
-- THVV 2011-07-28 5.2 add report on referring domain, make referrer reports NI
-- THVV 2011-09-17 5.21 make some fields 1023 instead of 255, change default print criteria
-- THVV 2011-12-28 5.22 add !JESSE
-- THVV 2012-01-15 5.23 added some bots to wtindexer
-- THVV 2012-08-28 5.231 minor additions to TLDs
-- THVV 2012-09-09 5.232 add "Java 1." to wtindexers, seeing a lot of these, maybe uptime checks
-- THVV 2012-09-09 5.233 add ".class.pack.gz" to wtexpected404
-- THVV 2012-10-15 5.234 add ".manifest" as "code"
-- THVV 2012-11-14 5.235 jquery.js and easySlider.js are boring
-- THVV 2012-12-03 5.236 new THVV IP
-- THVV 2013-01-21 5.237 more tweaks to wtindexers
-- THVV 2013-03-03 5.238 added a bunch of names to wthackfilenames
-- THVV 2013-03-17 5.239 ignore apple-touch-icon
-- THVV 2014-01-04 5.240 do ORDER BY hits.path instead of hits.filename
-- THVV 2014-01-04 5.241 fix filetype queries so the bars are not bigger than the total
-- THVV 2014-06-13 5.242 add trackback/index.html to wthackfilenames
-- THVV 2014-08-15 5.25 change query for attacks report to sort/group on source
-- THVV 2014-08-20 5.251 add add contentscan to spiders
-- THVV 2014-09-04 5.252 new THVV IP
-- THVV 2014-09-17 5.253 new THVV IP
-- THVV 2014-09-29 5.26 add query for shellshock attacks
-- THVV 2015-01-01 5.261 new THVV IP
-- THVV 2015-03-12 5.262 more crawler detection by domain and browser
-- THVV 2015-03-23 5.263 added refspam patterns
-- THVV 2015-04-08 5.264 added Jesse store IP
-- THVV 2015-04-09 5.265 added another refspam
-- THVV 2015-05-20 5.27 changed *set,logprint to *set,&logprint
-- THVV 2015-06-23 5.271 added another refspam
-- THVV 2015-07-17 5.272 new POS4 IP
-- THVV 2015-11-01 5.273 new crawlers and refspams
-- THVV 2016-01-04 5.274 new wtindexers, widened pie charts
-- THVV 2016-01-14 5.28 added table wtpiequeries, removed old pie chart queries
-- THVV 2016-01-29 5.281 new wtindexers
-- THVV 2016-02-02 5.282 mark top1-seo-service.com refspam
-- THVV 2016-03-29 5.283 add clean_hits q2 to delete internal Apache hits
-- THVV 2016-04-04 5.3 add wtwatch table
-- THVV 2016-04-04 5.31 add icevikatam to wtindexers
-- THVV 2016-08-05 5.32 modify queries so that MySQL 5.7.13 will not fail with ONLY_FULL_GROUP_BY.  Use MAX() rather than ANY_VALUE().
-- THVV 2016-08-15 5.321 fix bad MaxMind geoip for OCNJ
-- THVV 2016-10-10 5.322 fix bad MaxMind geoip for OCNJ
-- THVV 2016-10-20 5.323 MAX() fix needed adjustment for geoloc
-- THVV 2016-10-24 5.324 MAX() fix needed adjustment for repeated hits
-- THVV 2016-10-27 5.325 hide .eot and .woff, update wthackfilenames
-- THVV 2015-11-29 5.326 more refspam patterns
-- THVV 2017-01-27 document showanyway operation better
-- THVV 2017-03-30 5.327 add "/struts" to hackfilenames and .action to hackfiletype
-- THVV 2017-11-17 5.328 fix bad MaxMind geoip for OCNJ
-- THVV 2018-02-28 5.329 add GuzzleHttp to wtindexers
-- THVV 2018-04-16 5.33 delete all OPTIONS verbs, illegal hit from Turkey
-- THVV 2018-05-25 5.34 delete all CONNECT verbs, hits from China
-- THVV 2018-06-10 5.35 modify queries so that MySQL 8.0.11 will not fail with ONLY_FULL_GROUP_BY.
-- THVV 2018-10-07 5.351 add .pl1 etc as download class
-- THVV 2019-05-08 5.352 add applebot to wtrobotdomains
-- THVV 2020-04-21 5.353 add buncha names to wthackfilesnames
-- THVV 2020-05-23 5.354 transform 52.162.211. to !Microsoft
-- THVV 2021-03-15 6.0 add CHECKSWTFILES, RUNTIMEDIR and, REPORTDIR, TOOLSDIR to swt.sql
-- THVV 2021-04-04 5.355 add Markingdon and Toyon
-- THVV 2022-08-10 5.356 add HTTRACK to indexers, removed Toyon
-- THVV 2023-01-28 5.357 add crawl.amazonbot.amazon
-- ================================================================
-- Documentation of configurable items
-- .. this info will go into the help file
-- .. eventually it will be used to control the configuration app
DROP TABLE IF EXISTS wtconfigtabs;
CREATE TABLE wtconfigtabs(
 conftable VARCHAR(32) PRIMARY KEY, -- table name in swt
 confdesc VARCHAR(1023), -- description
 confdoc INT, -- 0 to not document in generated doc
 confadd INT -- 1 if the user can add rows
);
INSERT INTO wtconfigtabs VALUES
('wtboring','Boring pages. Discourage display of a visit in the important details.',1,1),
('wtcolors','Watched pages. Which pages should be shown in details and what color to display them in.',1,1),
('wtexpected404','Files expected to be not found. Suppress these from the not found listing.',1,1),
('wtglobalvalues','Global constants and configuration, documented above.',0,0),
-- what about wtglobvar?
('wthackfilenames','File names that do not exist on the site and that attackers look for.  Evidence of hacker attacks.',1,1),
('wthackfiletypes','File suffixes that do not exist on the site and that attackers look for.  Evidence of hacker attacks.',1,1),
('wtheadpages','Which pages are head pages.',1,1),
('wtindexers','Web crawlwers. Which user agents are web spiders etc.',1,1),
('wtlocalreferrerregexp','Local referrer definitions. Defines which domains count as part of the website.',1,1),
('wtpclasses','File assignments to visit class.',1,1),
('wtwatch','Watch for domains and browsers to display specially in details report.',1,1),
('wtpredomain','Transformations applied to the source domain of each hit before processing.',1,1),
('wtprepath','Transformations applied to file paths before processing.',1,1),
('wtprereferrer','Transformations applied to referrers before processing.',1,1),
('wtreferrercolor','Watched referrers. Which referring pages should be shown in details and in color.',1,1),
('wtreportoptions','Report option values, documented with the individual reports.',0,0),
('wtretcodes','Return code explanation. Describes the HTTP error codes.',1,0),
('wtrobotdomains','Robot domains. Which domains are used only by web crawlers.',1,1),
('wtshowanyway','Combinations of referrer and pathname to display even if wtsuffixclass says not to.',1,1),
('wtsuffixclass','Suffix classes. Grouping of file suffixes, and display options.',1,1),
('wtvclasses','Visit class definitions and color assignments.',1,1),
('wtvsources','Visit source definitions and color assignments. These sources are built into visitdata.pl.',1,0),
('wtpiequeries','Pie chart queries and weights.',1,0);

-- definition of the columns
DROP TABLE IF EXISTS wtconfigcols;
CREATE TABLE wtconfigcols(
 cconftable VARCHAR(32), -- table name in swt
 cconfcol VARCHAR(32), -- column name
 ccconfdesc VARCHAR(1023), -- value description as text
 ccconfmisc VARCHAR(1023), -- optional description, e.g. possible values
 PRIMARY KEY(cconftable, cconfcol)
);
INSERT INTO wtconfigcols VALUES
('wtglobalvalues','gloname','option name',''),
('wtglobalvalues','glovalue','option value',''),
('wtglobalvalues','glocomm','documentation','blank if not interesting to user'),
('wtreportoptions','optid','report name',''),
('wtreportoptions','optname','attribute name',''),
('wtreportoptions','optvalue','value of the attribute',''),
('wtreportoptions','optdoc','documentation','blank if user is not expected to change this attribute'),
('wtprereferrer','prereferrer','Perl subsitute commands','double basckslashes'),
('wtprereferrer','pwhy','documentation',''),
('wtpredomain','predomain','Perl subsitute commands','double basckslashes'),
('wtpredomain','pwhy','documentation',''),
('wtprepath','prepath','Perl subsitute commands','double basckslashes'),
('wtprepath','pwhy','documentation',''),
('wtvsources','sourceid','source ID from visitdata.pl','blank, indexer, refspam, search+hp, search, link+hp, link'),
('wtvsources','sourcecolor','color','gif file name'),
('wtvsources','sourcedetail','documentation',''),
('wtvclasses','vclass','visit class from wtpclasses',''),
('wtvclasses','vbarcolor','color','gif file name'),
('wtvclasses','vdetail','documentation',''),
('wtpclasses','cfilename','pathname or dirname ending in slash',''),
('wtpclasses','cclass','visit class',''),
('wtpclasses','cwhy','documentation',''),
('wtwatch','wtwdom','domain','regexp matched against visit domain'),
('wtwatch','wtwagt','domain','regexp matched against browser'),
('wtwatch','wtwnote','one char opcode: Hide, Impt, Summarize, Note followed by a note added to the visit',''),
('wtheadpages','headpage','pathname',''),
('wtheadpages','hpwhy','documentation',''),
('wtrobotdomains','dom','regexp matched against hit domain','double basckslashes'),
('wtrobotdomains','domwhy','documentaiton',''),
('wtindexers','indexer','regexp matched against browser name extracted from user agent','double basckslashes'),
('wtindexers','indexertype','type of user agent',''),
('wtindexers','indexerwhy','documentation',''),
('wtlocalreferrerregexp','regex','regexp matched against hits.referrerurl','double basckslashes'),
('wtlocalreferrerregexp','regexlocalwhy','documentation',''),
('wtexpected404','f404','regexp matched against file pathname','double basckslashes.'),
('wtexpected404','fwhy','documentation',''),
('wtretcodes','code','apache retcode',''),
('wtretcodes','good','display flag for details','1 = data was transferred. 2 = not a hit but show in details'),
('wtretcodes','css','css class',''),
('wtretcodes','meaning','documentation',''),
('wtreferrercolor','rcurl','regexp against hits.referrerurl','double basckslashes. should have domain name only, e.g. digg\\\\.com, not www.digg.com/page3'),
('wtreferrercolor','rcclass','css class',''),
('wtreferrercolor','rcwhy','documentation',''),
('wtcolors','colfilename','regexp matched against hit path','double basckslashes'),
('wtcolors','colorclass','css class for color',''),
('wtcolors','colorwhy','documentation',''),
('wtpiequeries','tablecode','3 letter report code','e.g. NWO'),
('wtpiequeries','longweight','3 digit weight for long report','highest displays first, 000 suppresses'),
('wtpiequeries','shortweight','3 digit weight for short report','highest displays first, 000 suppresses'),
('wtpiequeries','byvarvar','variable bound by query for v',''),
('wtpiequeries','scalevalue','scale factor',''),
('wtpiequeries','units','units or blank',''),
('wtpiequeries','title','report title',''),
('wtpiequeries','qvalue','SQL query',''),
('wtboring','borfilename','file pathname regexp matched against hit path','double backslashes'),
('wtboring','borweight','boringness','usually 1'),
('wtboring','borwhy','documentation',''),
('wthackfiletypes','hackfiletype','file types (suffixes) that do not exist on the site and that attackers look for','without dot'),
('wthackfiletypes','hackwhy','documentation',''),
('wthackfilenames','hackfileregex','regexp file names that do not exist on the site and that attackers look for',''),
('wthackfilenames','hackwhy','documentation',''),
('wtsuffixclass','suf','suffix without dot',''),
('wtsuffixclass','sufdetailsshort','flag 1 if in short details',''),
('wtsuffixclass','sufdetailslong','flag 1 if in long details',''),
('wtsuffixclass','sufclass','class with unique first letter, e.g. html, graphic',''),
('wtshowanyway','referrer','referring page','specify with www and without will be done also'),
('wtshowanyway','pathrexp','regexp matched against path','double backslashes and escape slashes');

-- --------------------------------------------------------------
-- Three things can have the value "indexer"
-- browser type: set in visitdata.pl from  wtindexers and possible hard code
-- visit class: set in visitdata.pl from browser type, wtrobotdomains, or touching robots.txt
-- visit source: set in visitdata.pl from visit class
-- --------------------------------------------------------------
-- Items that the user supplies the contents for 

-- watched pages
-- .. shown in color in the details and the page type reports
-- .. used by printvisitdetail.pl
-- .. also used by printvisitdetail to select important visits in the "criteria"
-- slashes in regexps must be preceded by two backslashes .. SQL leaves one, rexp unspecials the slash
DROP TABLE IF EXISTS wtcolors;
CREATE TABLE wtcolors(
 colfilename VARCHAR(255) PRIMARY KEY, -- matched as regexp against hits.path
 colorclass VARCHAR(32), -- css class in style sheet
 colorwhy VARCHAR(1023) -- document why
);
-- user may configure any number of entries
-- INSERT INTO wtcolors (colfilename, colorclass, colorwhy) VALUES
-- ('vvdd.js','inred','interesting');

-- boring pages
-- .. if a visit is mostly boring pages, don't show in the short report
-- .. used by the query for printvisitdetail.pl as hits.path REGEXP boringfilename
-- .. printvisitdetail then counts the boring pages and the "criteria" for the short report compares to total
-- any backslashes that are to be seen by Perl must be doubled to get past mysql
DROP TABLE IF EXISTS wtboring;
CREATE TABLE wtboring(
 borfilename VARCHAR(255) PRIMARY KEY, -- matched as regexp against hits.path
 borweight INT, -- how boring it is, usually 1
 borwhy VARCHAR(1023) -- document why
);
-- user may configure any number of additional entries
INSERT INTO wtboring (borfilename, borweight, borwhy) VALUES
('/swtdash\\.htmi',1,'monitoring file for THVV dashboard'), -- XXX move to swt-user
('/swtdash\\.csv',1,'monitoring file for THVV dashboard'), -- XXX move to swt-user
('/swt\\.js',1,'usage report'),
('/excanvas\\.js',1,'usage report'), -- 2011-06-09
('/piecanvas\\.js',1,'usage report'), -- 2011-06-09
('/jquery-.*\\.js',1,'multics menus'), -- 2012-11-14 -- XXX move to swt-user
('/easySlider.*\\.js',1,'multics pictures'), -- 2012-11-14 -- XXX move to swt-user
('/swtreport\\.html',1,'usage report');

-- watched referrers
-- .. shown in color in the details
-- .. these should be domains only
DROP TABLE IF EXISTS wtreferrercolor;
CREATE TABLE wtreferrercolor(
 rcurl VARCHAR(255) PRIMARY KEY, -- matched as regexp against hits.referrerurl
 rcclass VARCHAR(32), -- css class in style sheet
 rcwhy VARCHAR(1023) -- document why
);
-- user may configure any number of entries
-- INSERT INTO wtreferrercolor (rcurl, rcclass, rcwhy) VALUES
-- ('wikipedia.org','inolive','whee');

-- map visit class to color
-- used in filetype1.htmt, etc
-- valid colors: black, fuchsia, indigo, navy, purple, violet, blue, goldenrod, lightgreen, olive, red, white, cyan, gray, lime, orange, silver, yellow, darkblue, green, maroon, pink, teal

DROP TABLE IF EXISTS wtvclasses;
CREATE TABLE wtvclasses(
 vclass VARCHAR(32) PRIMARY KEY, -- class from wtpclasses
 vbarcolor varchar(32),
 vdetail varchar(1023)
);
-- user may add additional classes
INSERT INTO wtvclasses (vclass, vbarcolor, vdetail) VALUES
('indexer','bluepix.gif','reference by a web crawler'),
('','graypix.gif','visit class not identified');

-- map name against hits.path to visit class spec
-- used in visitdata.pl; loaded into a Perl hash
-- cfilename matches a file path or a directory prefix
-- the match is most specific first, so '/' is last
DROP TABLE IF EXISTS wtpclasses;
CREATE TABLE wtpclasses(
 cfilename VARCHAR(255) PRIMARY KEY, -- these are explicit filepaths or directory prefixes ending in slash
 cclass VARCHAR(255), -- this is a comma separated list of classes
 cwhy VARCHAR(1023) -- documentation
);
-- user may configure any number of pairs
-- INSERT INTO wtpclasses (cfilename, cclass, cwhy) VALUES
-- ('/cgi-bin/','multics',''),

-- which pages are "head pages" -- from user config
-- used in visitdata; loaded into a perl list; concept could be generalized
DROP TABLE IF EXISTS wtheadpages;
CREATE TABLE wtheadpages(
 headpage VARCHAR(255) PRIMARY KEY,
 hpwhy VARCHAR(1023) -- documentation
);
INSERT INTO wtheadpages (headpage, hpwhy) VALUES
('index.html','apache main page');
-- user may add additional headpages in swt-user.sql

-- robot domains regexp, all hits from these are web crawlers, regexp matched against hit domain
-- used in visitdata; loaded into a perl list, ugh
-- hits from these domains will set the "browser type" to "indexer" and will also set the "visit class" and "vsit source"
-- any backslashes that are to be seen by Perl must be doubled to get past mysql
DROP TABLE IF EXISTS wtrobotdomains;
CREATE TABLE wtrobotdomains(
 dom VARCHAR(255) PRIMARY KEY,
 domwhy VARCHAR(1023) -- documentation
);
INSERT INTO wtrobotdomains (dom, domwhy) VALUES
('188\\.92\\.76\\.167','LV'), -- 2013-03-19 bothering Birch and Beebe with fufeguba.z-26.us and vonemac.hostweb4u.info hits
('^crawl',''),
('^robot','2009-03-27'),
('crawl\\.amazonbot','2023-01-28'), -- 52-70-240-171.crawl.amazonbot.amazon[us/Ashburn VA]
('^.*crawl.*looksmart\\.com',''),
('^.*crawl\\.baidu\\.com',''), -- 2015-03-12
('semalt\\.com',''), -- 2015-03-12
('^.*\\.applebot\\.apple\\.com',''), -- 2019-05-08
('amazonaws\\.com','2009-09-08 anything at amazonaws is a crawler'),
('static-208-80-19.*\\.as13448\\.com','2009-07-01 Websense, scans for porn'),
('208\\.80\\.19[2-9]\\..*','2009-07-04 Websense, scans for porn'), -- 208.80.192.0 - 208.80.199.255
('inktomisearch\\.com','seems to mix crawling with lookup');
-- user may add additional domains in swt-user.sql

-- webcrawlers regexp, matched against lowercased browser name extracted from hits.browser, came from user_agent
-- used in visitdata; loaded into a perl hash, ugh
-- double any backslashes
-- this will set the "browser type" and if it is "indexer" will also set the "visit class" and "vsit source"
-- This type will show in the browser type pie chart and the browser listings
DROP TABLE IF EXISTS wtindexers;
CREATE TABLE wtindexers(
 indexer VARCHAR(255) PRIMARY KEY, -- regexp matched against browser
 indexertype VARCHAR(32), -- what type this is.. may be "indexer", "phone", "rss", "bulk"
 indexerwhy VARCHAR(1023) -- documentation
);
INSERT INTO wtindexers (indexer, indexertype, indexerwhy) VALUES
-- what about Google Toolbar and Google Desktop
('nokia','phone',''),  -- 2007-07-27
('iphone','phone',''),  -- 2007-07-27
('wap-browser','phone',''),  -- 2016-01-04
('feedly','rss','rss reader'),  -- 2016-01-04
('page2rss','rss','rss reader'),  -- 2016-01-04
('newsbeuter','rss','rss reader'),  -- 2016-01-04
('bloglines','rss','rss reader'),  -- 2007-07-27
('feedchecker','rss','rss reader'),  -- 2007-07-27
('feedfetcher','rss','rss reader'),  -- 2007-07-27
('newsgator','rss','rss reader'),  -- 2007-07-27
('rssreader','rss','rss reader'),  -- 2007-07-27
('liferea','rss','rss reader'),  -- 2007-07-29
('libcurl','bulk',''),  -- 2007-07-27
('link-checker','bulk',''),  -- 2007-07-27
('httrack','indexer',''),  -- 2013-01-21 website copier, indexer 2022-08-10
('wget','bulk',''),  -- 2007-07-27
('008','indexer',''),  -- 2011-06-15 .. see http://www.80legs.com/webcrawler.html
('libcrawl','indexer',''),  -- 2013-01-21 Chinese sites
('masscan','indexer',''),  -- 2015-02-28 netscan.gtisc.gatech.edu
('netscan','indexer',''),  -- 2015-03-12 netscan.gtisc.gatech.edu
('hypercrawl','indexer',''),  -- 2015-03-12 
('yandex','indexer',''),  -- 2013-01-21 russian
('ezooms','indexer',''),  -- 2011-06-09
('icevikatam','indexer',''),  -- 2016-04-06
('siteuptime.com','indexer',''),
('java/1\\.','indexer',''),
('java 1\\.','indexer',''), -- 2012-09-10
('libwww-perl','indexer',''),
('linklint','indexer',''),
('netcraftsurveyagent','indexer',''), -- 2009-07-11
('acadiauniversitywebcensusclient','indexer',''),
('ostc-link-checkerlibwww-perl','indexer',''),
('bot','indexer',''), -- 2007-07-26, generic
('turnitin','indexer',''), -- 2023-01-20, generic
('sleuth','indexer',''), -- 2013-01-22
('answerbus','indexer',''),
('appie','indexer',''),
('arachnoidea','indexer',''),
('aspseek','indexer',''),
('boitho.com-dc','indexer',''),
('cartographer','indexer',''),
('centrum-checker','indexer',''),
('cerberian drtrs','indexer',''),
('cfetch','indexer',''),
('cfnetwork','indexer',''),
('crawler','indexer',''),
('digimarc','indexer',''),
('echo','indexer',''),
('emailsiphon','indexer',''),
('ferret','indexer',''),
('findexa','indexer',''), -- added 2007-11-24, flamme.gulesider.no
('findlinks','indexer',''),
('go .* package http','indexer',''), -- 2016-01-04
('go-http-client','indexer',''), -- 2016-01-04
('megaindex','indexer',''), -- 2016-01-04
('linkchecker','indexer',''), -- 2016-01-04
('eventmachine httpclient','indexer',''), -- 2016-01-04
('typhoeus','indexer',''), -- 2016-01-04
('grub-client','indexer',''),
('gulliver','indexer',''),
('heritrix','indexer',''), -- internet archiver, added 2007-07-12
('archive\\.org_bot','indexer',''), -- internet archiver, added 2012-01-15
('ihwebchecker','indexer',''), -- Korea, added 2012-01-15
('contentscan','indexer',''), -- NetShelter added 2014-08-20
('litefinder','indexer',''), -- added 2007-11-23 after over 4000 hits in one day, also blocked in .htaccess
('indy library','indexer',''), -- added 2007-11-23
('offline navigator','indexer',''), -- added 2007-11-23
('webimages','indexer',''), -- added 2007-11-23
('webcapture','indexer',''), -- added 2007-11-23
('disco','indexer',''), -- added 2007-11-23
('sbider','indexer',''), -- added 2007-11-23
('gigablastopensource','indexer',''), -- added 2016-01-24
('stratagems kumo','indexer',''), -- added 2016-01-29
('guzzlehttp','indexer',''), -- added 2018-02-28
('htdig','indexer',''),
('hubater','indexer',''),
('ia_archiver','indexer',''),
('ichiro','indexer',''),
('iltrovatore-setaccio','indexer',''),
('infoseek sidewinder','indexer',''),
('jeeves/teoma','indexer',''),
('larbin','indexer',''),
('matrix','indexer',''),
('mercator','indexer',''),
('missigua','indexer',''),
('moget','indexer',''),
('msnptc','indexer',''),
('NetShelter ContentScan','indexer',''), -- 2015-11-01
('nutch','indexer',''), -- 2007-07-27
('ocelli','indexer',''),
('page_verifier','indexer',''),
('perman surfer','indexer',''),
('pompos','indexer',''),
('scooter','indexer',''),
('scoutjet','indexer',''), -- 2009-09-25
('search.ch','indexer',''),
('shopwiki','indexer',''),
('slurp','indexer',''),
('snap.com','indexer',''),
('speedy','indexer',''),
('spider','indexer',''),
('teleport','indexer',''),
('walker','indexer',''),
('webalta','indexer',''),  -- 2008-10-30
('webcollage','indexer',''),
('webcopier','indexer',''),
('wisewire-widow','indexer',''),
('www.first-search.com','indexer',''),
('yahooseeker','indexer',''),
('zeus','indexer','');
-- users may add additional inddexers

-- which referrers to treat as local
-- regexp matched against hits.referrerurl
-- .. used in illegal referrer report query to ignore local hits
-- .. used in day hits by query, referrer and engine to ignore local hits
-- .. used in local nav query to select local hits
-- .. and in visitdata to assign visit source
-- .. used in cumulative referrer update to skip locals
DROP TABLE IF EXISTS wtlocalreferrerregexp;
CREATE TABLE wtlocalreferrerregexp(
 regex VARCHAR(255) PRIMARY KEY,
 regexlocalwhy VARCHAR(1023) -- documentation
);
-- INSERT INTO wtlocalreferrerregexp (regex, regexlocalwhy) VALUES
-- ('^http://multicians.org','');

-- watch list specifies special action from printvisitdetail
-- watched domains regexp matched against hit domain
-- watched browser regexp matched against browser
-- notes, first letter is an opcode
-- I force a visit to be interesting
-- H hide the whole visit
-- S summarize visit, ie hide detail, annotate with rest of "wtwnote"
-- N annotate visit with rest of "wtwnote"
DROP TABLE IF EXISTS wtwatch;
CREATE TABLE wtwatch(
 wtwdom VARCHAR(255), -- domain rexp
 wtwagt VARCHAR(255), -- UserAgent rexp
 wtwnote VARCHAR(1023), -- note.. first char is the opcode
 PRIMARY KEY(wtwdom, wtwagt)
);
INSERT INTO wtwatch (wtwdom, wtwagt, wtwnote) VALUES
('','MJ12bot','SMJ12bot SEO indexer'); -- summarize MJ12bot

-- transformations logvisits.pl applies to raw web log hit domain
-- each one is a Perl substitute command
-- used by logvisits; loaded into a Perl list
-- backslashes should be doubled
DROP TABLE IF EXISTS wtpredomain;
CREATE TABLE wtpredomain(
 predomain VARCHAR(255) PRIMARY KEY,
 pwhy VARCHAR(1023) -- documentation
);
INSERT INTO wtpredomain (predomain, pwhy) VALUES
-- ('s~(99-72-225-37\\.lightspeed\\.sntcca\\.sbcglobal\\.net)~!REDCURBS $1~i','2015-04-08'), -- XXX move to swt-user
-- ('s~^(73\\.215\\.248\\.73)~!THVV $1~i','2015-01-01'); -- rare, rdns fail -- XXX move to swt-user
('s~52\\.162\\.211\\.~!Microsoft 52.162.211.~i','Bing maybe'),
('s~23\\.96\\.~!Microsoft 23.96.~i','Bing maybe'),
('s~23\\.97\\.~!Microsoft 23.97.~i','Bing maybe'),
('s~23\\.98\\.~!Microsoft 23.98.~i','Bing maybe'),
('s~23\\.99\\.~!Microsoft 23.99.~i','Bing maybe'),
('s~23\\.100\\.~!Microsoft 23.100.~i','Bing maybe'),
('s~23\\.101\\.~!Microsoft 23.101.~i','Bing maybe'),
('s~23\\.102\\.~!Microsoft 23.102.~i','Bing maybe'),
('s~23\\.103\\.~!Microsoft 23.1003.~i','Bing maybe'),
('c-98-35-69-208\\.hsd1\\.ca\\.comcast\\.net.us.San Jose CA.~!MKG c-98-35-69-208.hsd1.ca.comcast.net[us/San Jose CA]~i','MaxMind'), -- 2021-04-04 -- XXX move to swt-user
('s~c-73-215-248-73\\.hsd1\\.nj\\.comcast\\.net.us.Ocean City NJ.~!THVV c-73-215-248-73.hsd1.nj.comcast.net[US/Ocean City NJ]~i','MaxMind'), -- XXX move to swt-user
('s~c-73-215-248-73\\.hsd1\\.nj\\.comcast\\.net.us.Ocean View NJ.~!THVV c-73-215-248-73.hsd1.nj.comcast.net[US/Ocean City NJ]~i','01/15/18, MaxMind fail'), -- XXX move to swt-user
('s~c-73-215-248-73\\.hsd1\\.nj\\.comcast\\.net.us.Marmora NJ.~!THVV c-73-215-248-73.hsd1.nj.comcast.net[US/Ocean City NJ]~i','04/10/18, MaxMind fail'); -- XXX move to swt-user
-- ('s~c-73-215-248-73\\.hsd1\\.nj\\.comcast\\.net.us/Ocean View NJ.~!THVV c-73-215-248-73.hsd1.nj.comcast.net[US/Ocean City NJ]~i','02/11/17, MaxMind fail'), -- XXX move to swt-user
-- ('s~c-73-215-248-73\\.hsd1\\.nj\\.comcast\\.net.us/Philadelphia PA.~c-73-215-248-73.hsd1.nj.comcast.net[US/Ocean City NJ]~i','10/10/16, MaxMind fail'), -- XXX move to swt-user
-- ('s~c-73-215-248-73\\.hsd1\\.nj\\.comcast\\.net.us/Newtown PA.~c-73-215-248-73.hsd1.nj.comcast.net[US/Ocean City NJ]~i','8/5/16, MaxMind fail'); -- XXX move to swt-user
-- 

-- transformations logvisits.pl applies to raw web log referrer domain
-- each one is a Perl substitute command
-- commands may not contain '
-- any backslashes that are to be seen by Perl must be doubled to get past mysql
-- used by logvisits.pl; loaded into a Perl list
-- careful here, these regexps can have a performance impact.  For 16K records, logvisits went from 12.4 sec to 15.8 when I added 11 webmail transforms.
DROP TABLE IF EXISTS wtprereferrer;
CREATE TABLE wtprereferrer(
 prereferrer VARCHAR(255) PRIMARY KEY,
 pwhy VARCHAR(1023) -- documentation
);
INSERT INTO wtprereferrer (prereferrer, pwhy) VALUES
('s~^https?://[-.a-z0-9]*\\.xyz/.*$~refspam~i','referrer spam'), -- 20161129
('s~^https?://[-.a-z0-9]*\\.top/.*$~refspam~i','referrer spam'), -- 20161129
('s~^https?://[-.a-z0-9]*\\.accountant/.*$~refspam~i','referrer spam'), -- 20161129
('s~^https?://.*onlinepharmacy.*$~refspam~i','referrer spam'), -- 20181030
('s~^https?://keywords-monitoring-your-success\\.com.*$~refspam~i','referrer spam'), -- 20160501
('s~^https?://burger-imperia\\.com.*$~refspam~i','referrer spam'), -- 20160315
('s~^https?://pizza-imperia\\.com.*$~refspam~i','referrer spam'), -- tricky registry, multiple hosts
('s~^https?://top1-seo-service\\.com.*$~refspam~i','referrer spam'), -- 20160201 SEO crawler, at least mark it refspam, shd really be indexer
('s~^https?://sergeshutov\\.ru/.*$~refspam~i','referrer spam'), -- 20151109
('s~^https?://rankings-analytics\\.com/.*$~refspam~i','referrer spam'), -- 20151031
('s~^https?://okthatsnice\\.com/.*$~refspam~i','referrer spam'), -- 20150921
('s~^https?://success-seo\\.com/.*$~refspam~i','referrer spam'), -- 20150706
('s~^https?://100dollars-seo\\.com/.*$~refspam~i','referrer spam'), -- 20150623
('s~^https?://videos-for-your-business\\.com.*$~refspam~i','referrer spam'), -- 201500707
('s~^https?://zaimy-rf\\.ru/.*$~refspam~i','referrer spam'), -- 20150430
('s~^https?://best-seo-solution.com/.*$~refspam~i','referrer spam'), -- 20150409
('s~^https?://best-seo-offer.com/.*$~refspam~i','referrer spam'), -- 20150411
('s~^.*\\.gq/.*$~refspam~i','referrer spam'), -- 20150323,.gq domain
('s~^.*buttons-for-website\\.com.*$~refspam~i','referrer spam'), -- 20150319, buttons-for-website
('s~^.*buttons-for-your-website\\.com.*$~refspam~i','referrer spam'), -- 20150411
('s~^.*semalt\\.com.*$~refspam~i','referrer spam'), -- 20150313, http://semalt.semalt.com/crawler.php?u=http://formyfriendswithmacs.com
-- ('s~^.*mp3skylines.*$~refspam~i','referrer spam'), -- 20071205, remove referrer spam ref
-- ('s~^.*ismymovies.com.*$~refspam~i','referrer spam'), -- 20071205, remove referrer spam ref
-- ('s~^.*sixpackabdominal.com.*$~refspam~i','referrer spam'), -- 20090927, remove referrer spam ref
('s~^https?://[^/]*webmail\\.aol\\.com/.*$~webmail:aol.com~i','webmail'),
('s~^https?://mailcenter[0-9]*\\.comcast\\.net/.*$~webmail:comcast.net~i','webmail'),
('s~^https?://[^/]*\\.mail\\.yahoo\\.com/.*$~webmail:yahoo.com~i','webmail'),
('s~^https?://(bmail|cafemail|netmail|email|webmail|mail|mymail|webedge|owebmail)[0-9]*\\.([^/]*)/.*$~webmail:$2~i','webmail'),
('s~^https?://([^/]*)/squirrelmail/.*$~webmail:$1~i','webmail'),
('s~^https?://([^/]*)/cgi-bin/openwebmail/.*$~webmail:$1~i','webmail'),
('s~^https?://[^/]*\\.hotmail.msn.com.*$~webmail:hotmail.msn.com~i','webmail'),
('s~^https?://[^/]*\\.mail.live.com/mail/.*$~webmail:live.com~i','webmail'),
('s~^https?://[^/]*\\.mail.lycos.com/mail/.*$~webmail:lycos.com~i','webmail'),
('s~^https?://[^/]*\\.email.excite.com/.*$~webmail:excite.com~i','webmail'),
('s~^https?://www.mac.com/WebObjects/Webmail.*$~webmail:mac.com~i','webmail');
-- ('s~\\[unknown origin\\]~~i','');

-- transformations logvisits.pl applies to raw web log hit path before splitting out filename
-- each one is a Perl substitute command
-- commands may not contain '
-- any backslashes that are to be seen by Perl must be doubled to get past mysql
-- used by logvisits; loaded into a Perl list
DROP TABLE IF EXISTS wtprepath;
CREATE TABLE wtprepath(
 prepath VARCHAR(255) PRIMARY KEY,
 pwhy VARCHAR(1023) -- documentation
);
-- INSERT INTO wtprepath (prepath, pwhy) VALUES
-- ('s~/^(SOL-FTTB\\.115\\.115\\.118.*sovam\\.net\\.ua.*?) 200 (.*)$/$1 400 $2/','refspam');

-- filenames whose 404 is uninteresting
-- each one is a regexp matched against file pathname
-- backslashes should be doubled
DROP TABLE IF EXISTS wtexpected404;
CREATE TABLE wtexpected404(
 f404 VARCHAR(255) PRIMARY KEY,
 fwhy VARCHAR(1023) -- documentation
);
INSERT INTO wtexpected404 (f404, fwhy) VALUES
('/apple-touch-icon.*\\.png$','iphone'), -- 20130317
('\\.class\\.pack\\.gz$','new Java thing'), -- 20120916
('MSOffice/cltreq\\.asp$','MSIE discuss toolbar'),
('_vti_bin/owssvr\\.dll$','MSIE discuss toolbar'),
('_vti_bin/_vti_aut/author\\.dll$','MSIE discuss toolbar'),
('_vti_bin/_vti_aut/author\\.exe$','MSIE discuss toolbar'),
('BeanInfo\\.class$','Java'),
('COMClassObject\\.class$','Microsoft Java'),
('default\\.class$','Java');

-- --------------------------------------------------------------
-- constants, config could modify

-- map visit source from visitdata.pl to color
-- used in filetype1.htmt, etc
DROP TABLE IF EXISTS wtvsources;
CREATE TABLE wtvsources(
 sourceid VARCHAR(32) PRIMARY KEY,
 sourcecolor varchar(32),
 sourcedetail varchar(1023)
);
INSERT INTO wtvsources (sourceid, sourcecolor, sourcedetail) VALUES
('','graypix.gif','source not identified'),
('indexer','bluepix.gif','reference by web crawler'),
('refspam','olivepix.gif','reference by spammer'),
('search+hp','orangepix.gif','search to a head page'),
('search','redpix.gif','search'),
('link+hp','purplepix.gif','link to a head page'),
('link','greenpix.gif','link');
-- ('bulk','cyanpix.gif','bulk transfers'); -- Wget, FeedFetcher

-- Classification of return codes. good = 1 means data was transferred. good = 2 means it's not a hit but show in details
DROP TABLE IF EXISTS wtretcodes;
CREATE TABLE wtretcodes(
 code CHAR(3) PRIMARY KEY, -- Apache return code
 good INT,                 -- good = 1 means data was transferred. good = 2 means it's not a hit but show in details
 css VARCHAR(12),          -- CSS class to use
 meaning varchar(64)       -- meaning for retcode report
);
INSERT INTO wtretcodes (code, good, css, meaning) VALUES
('100', 0, '', 'Continue'),
('101', 0, '', 'Switching Protocols'),
('200', 1, '', 'OK'),
('201', 0, '', 'Created'),
('202', 0, '', 'Accepted'),
('203', 0, '', 'Non-Authoritative Information'),
('204', 0, '', 'No Content'),
('205', 0, '', 'Reset Content'),
('206', 1, '', 'Partial Content'),
('300', 0, '', 'Multiple Choices'),
('301', 0, '', 'Moved Permanently'),
('302', 0, '', 'Moved Temporarily'),
('303', 0, '', 'See Other'),
('304', 1, 'cac', 'Not Modified'),
('305', 0, '', 'Use Proxy'),
('400', 0, '', 'Bad Request'),
('401', 0, '', 'Unauthorized'),
('402', 0, '', 'Payment Required'),
('403', 0, '', 'Forbidden'),
('404', 2, 'fnf', 'Not Found'),
('405', 0, '', 'Method Not Allowed'),
('406', 0, '', 'Not Acceptable'),
('407', 0, '', 'Proxy Authentication Required'),
('408', 0, '', 'Request Timeout'),
('409', 0, '', 'Conflict'),
('410', 0, '', 'Gone'),
('411', 0, '', 'Length Required'),
('412', 0, '', 'Precondition Failed'),
('413', 0, '', 'Request Entity Too Large'),
('414', 0, '', 'Request-URI Too Long'),
('415', 0, '', 'Unsupported Media Type'),
('500', 0, '', 'Internal Server Error'),
('501', 0, '', 'Not Implemented'),
('502', 0, '', 'Bad Gateway'),
('503', 0, '', 'Service Unavailable'),
('504', 0, '', 'Gateway Timeout'),
('505', 0, '', 'HTTP Version Not Supported');

-- table of filetypes to detect hack attacks
-- These are file types (suffixes) that do not exist on the site and that attackers look for.
-- .. if your site uses any of these, delete them from the list in swt-user.sql
-- .. if you see other files not found that you decide are attacks, add them in swt-user.
DROP TABLE IF EXISTS wthackfiletypes;
CREATE TABLE wthackfiletypes(
 hackfiletype varchar(32) PRIMARY KEY, -- filetype
 hackwhy VARCHAR(1023) -- documentation
);
INSERT INTO wthackfiletypes (hackfiletype, hackwhy) VALUES
('action','apache struts executable'), -- 2017-03-31
('exe','windows executable'),
('dll','windows library'),
('asp','windows server page'),
('aspx','windows server page'),
('axd','windows server page'), -- 2010-07-18
('pl','perl, none served here'),
('php5','PHP5, none here'),
('php4','PHP4, none here'),
('phps','PHPS, none here'),
('php3','PHP3, none here'),
('php','PHP, none here'); -- SRS must override

-- table of filenames to detect hack attacks, and to clean up the 404 report
-- these are files that do not exist on the site and that attackers look for
-- .. if your site uses any of these, delete them from the list in swt-user.sql
-- .. if you see other files not found that you decide are attacks, add them in swt-user.
-- backslashes should be doubled
DROP TABLE IF EXISTS wthackfilenames;
CREATE TABLE wthackfilenames(
 hackfileregex varchar(32) PRIMARY KEY, -- filename
 hackwhy VARCHAR(1023) -- documentation
);
INSERT INTO wthackfilenames (hackfileregex, hackwhy) VALUES
('/wp-includes/','hackers'), -- 2020-04-21
('/guestbook','hackers'), -- 2020-04-21
('/phpunit','hackers'), -- 2020-04-21
('mainfunction\\.cgi','hackers'), -- 2020-04-21
('/administrator/index\\.html$',''), -- 2020-04-21
('/struts','Apache Struts exploit'), -- 2017-03-30
('trackback/index\\.html$',''), -- 2014-06-13
('signup$',''), -- 2013-03-03
('login$',''), -- 2013-03-03
('phpmyadmin$',''), -- 20161027
('register$',''), -- 2013-03-03
('user/password$',''), -- 2013-03-17
('phpmanager/index\\.html$',''), -- 2013-03-03
('phpmyadmin2?/index\\.html$',''), -- 2013-03-03
('admin/index\\.html$',''), -- 2013-03-03
('mysql/index\\.html$',''), -- 2013-03-03
('register/index\\.html$',''), -- 2013-03-03
('signup/index\\.html$',''), -- 2013-03-17
('sign_up\\.html$',''), -- 2013-03-17
('webdb/index\\.html$',''), -- 2013-03-03
('websql/index\\.html$',''), -- 2013-03-03
('sqlweb/index\\.html$',''), -- 2013-03-03
('yabb\\.cgi/index\\.html$',''), -- 2013-03-03
('yabb\\.pl/index\\.html$',''), -- 2013-03-03
('cpanelsql/index\\.html$',''), -- 2013-03-03
-- ('SelectPic\\.asp$',''), -- specific bad ASP files, not needed if asp is in wthackfiletypes
-- ('diy\\.asp$',''),
-- ('key\\.asp$',''),
-- ('login\\.asp$',''),
-- ('SqlIn\\.asp$',''),
-- ('tmdqq\\.asp$',''),
-- ('upfile_flash\\.asp$',''),
-- ('upload_flash\\.asp$',''),
('nph-proxy\\.cgi$',''),
('nph-vv\\.cgi$',''),
('nph-oipf\\.cgi$',''),
('nph-index\\.cgi$',''),
('nph-proxyb\\.cgi$',''),
-- ('nph-proxy\\.pl$',''), -- specific bad PL files, not needed if pl is in wthackfiletypes
-- ('nph-vv\\.pl$',''),
-- ('nph-oipf\\.pl$',''),
-- ('nph-index\\.pl$',''),
-- ('nph-proxyb\\.pl$',''),
-- ('openwebmail\\.pl$',''),
-- ('FormMail\\.pl$',''),
-- ('awstats\\.pl$',''),
-- ('Classes\\.php$',''), -- specific bad PHP files, not needed if php is in wthackfiletypes
-- ('SignIn\\.php$',''),
-- ('adxmlrpc\\.php$',''),
-- ('application\\.php$',''),
-- ('advanced1\\.php$',''),
-- ('ibrowser\\.php$',''),
-- ('post_comment\\.php$',''),
-- ('cmd\\.php$',''),
-- ('captionator\\.php$',''),
-- ('compose\\.php$',''),
-- ('read_dump\\.phpmain\\.php$',''),
-- ('main\\.phpmain\\.php$',''),
-- ('config_settings\\.php$',''),
-- ('file_upload\\.php$',''),
-- ('header\\.inc\\.php$',''),
-- ('help\\.php$',''),
-- ('image_upload\\.php$',''),
-- ('index\\.php$',''),
-- ('index2\\.php$',''),
-- ('left_main\\.php$',''),
-- ('login\\.php$',''),
-- ('main\\.php$',''),
-- ('moblog_lib\\.php$',''),
-- ('nonexistentfile\\.php$',''),
-- ('protection\\.php$',''),
-- ('prx\\.php$',''),
-- ('read_body\\.php$',''),
-- ('right_main\\.php$',''),
-- ('search\\.php$',''),
-- ('security\\.php$',''),
-- ('send_reminders\\.php$',''),
-- ('sql\\.php$',''),
-- ('template\\.php$',''),
-- ('thisdoesnotexistahaha\\.php$',''),
-- ('webmail\\.php$',''),
-- ('xmlrpc\\.php$',''),
-- ('messagesL\\.php3$',''),
('/phpMyAdmin.*/index\\.html$',''),
('/pma/index\\.html$',''),
('/db/index\\.html$',''),
('/dbadmin/index\\.html$',''),
('ThisFileMustNotExist','sniffing server type');

-- --------------------------------------------------------------
-- constants

-- Explanation of domain suffixes
-- updated from ISO as of may 2007, gTLDs added 2010-08-07, checked 2015-06-06
DROP TABLE IF EXISTS countrynames;
CREATE TABLE countrynames(
 cncode CHAR(8) PRIMARY KEY,
 cnname VARCHAR(64),
 cncontinent VARCHAR(64) -- blank if none
);
INSERT INTO countrynames (cncode, cnname, cncontinent) VALUES
('a1', 'Anonymous Proxy', ''),
('a2', 'Satellite provider', ''),
('ad', 'Andorra', 'Europe'),
('ae', 'United Arab Emirates', 'Asia'),
('af', 'Afghanistan', 'Asia'),
('ag', 'Antigua and Barbuda', 'Caribbean'),
('ai', 'Anguilla', 'Caribbean'),
('al', 'Albania', 'Europe'),
('am', 'Armenia', 'Europe'),
('an', 'Netherlands Antilles', 'Caribbean'), -- not in 2015-06-06
('ao', 'Angola', 'Africa'),
('ap', 'Asia/Pacific unassigned', 'Asia'),
('aq', 'Antarctica', 'Antarctica'),
('ar', 'Argentina', 'South America'),
('as', 'American Samoa', 'Pacific'),
('at', 'Austria', 'Europe'),
('au', 'Australia', 'Australia'),
('aw', 'Aruba', 'Caribbean'),
('ax', 'Aland Islands', 'Europe'),
('az', 'Azerbaijan', 'Asia'),
('ba', 'Bosnia and Herzegovina', 'Europe'),
('bb', 'Barbados', 'Caribbean'),
('bd', 'Bangladesh', 'Asia'),
('be', 'Belgium', 'Europe'),
('bf', 'Burkina Faso', 'Africa'),
('bg', 'Bulgaria', 'Europe'),
('bh', 'Bahrain', 'Asia'),
('bi', 'Burundi', 'Africa'),
('bj', 'Benin', 'Africa'),
('bl', 'Saint Bartelemey', 'Caribbean'), -- 20120828
('bm', 'Bermuda', 'North America'),
('bn', 'Brunei Darussalam', 'Asia'),
('bo', 'Bolivia', 'South America'),
('bq', 'Bonaire, Saint Eustatius and Saba', 'Caribbean'), -- 20120828
('br', 'Brazil', 'South America'),
('bs', 'Bahamas', 'Caribbean'),
('bt', 'Bhutan', 'Asia'),
('bv', 'Bouvet Island', 'Atlantic'),
('bw', 'Botswana', 'Africa'),
('by', 'Belarus', 'Europe'),
('bz', 'Belize', 'Central America'),
('ca', 'Canada', 'North America'),
('cc', 'Cocos (Keeling) Islands', 'Australia'),
('cd', 'Congo, The Democratic Republic of the', 'Africa'),
('cf', 'Central African Republic', 'Africa'),
('cg', 'Congo', 'Africa'),
('ch', 'Switzerland', 'Europe'),
('ci', 'Cote D&#39;Ivoire (Ivory Coast)', 'Africa'),
('ck', 'Cook Islands', 'Pacific'),
('cl', 'Chile', 'South America'),
('cm', 'Cameroon', 'Africa'),
('cn', 'China', 'Asia'),
('co', 'Colombia', 'South America'),
('cr', 'Costa Rica', 'Central America'),
('cs', 'Czechoslovakia (former)', 'Europe'),
('cu', 'Cuba', 'Caribbean'),
('cv', 'Cape Verde', 'Europe'),
('cx', 'Christmas Island', 'Pacific'),
('cy', 'Cyprus', 'Europe'),
('cz', 'Czech Republic', 'Europe'),
('de', 'Germany', 'Europe'),
('dj', 'Djibouti', 'Africa'),
('dk', 'Denmark', 'Europe'),
('dm', 'Dominica', 'Caribbean'),
('do', 'Dominican Republic', 'Caribbean'),
('dz', 'Algeria', 'Africa'),
('ec', 'Ecuador', 'Central America'),
('ee', 'Estonia', 'Europe'),
('eg', 'Egypt', 'Africa'),
('eh', 'Western Sahara', 'Africa'),
('er', 'Eritrea', 'Africa'),
('es', 'Spain', 'Europe'),
('et', 'Ethiopia', 'Africa'),
('fi', 'Finland', 'Europe'),
('fj', 'Fiji', 'Pacific'),
('fk', 'Falkland Islands (Malvinas)', 'South America'),
('fm', 'Micronesia, Federated States of', 'Pacific'),
('fo', 'Faroe Islands', 'Europe'),
('fr', 'France', 'Europe'),
('fx', 'France, Metropolitan', 'Europe'),
('ga', 'Gabon', 'Africa'),
('gb', 'Great Britain (UK)', 'Europe'),
('gd', 'Grenada', 'Caribbean'),
('ge', 'Georgia', 'Asia'),
('gf', 'French Guiana', 'South America'),
('gg', 'Guernsey', 'Europe'),
('gh', 'Ghana', 'Africa'),
('gi', 'Gibraltar', 'Europe'),
('gl', 'Greenland', 'Europe'),
('gm', 'Gambia', 'Africa'),
('gn', 'Guinea', 'Africa'),
('gp', 'Guadeloupe', 'Caribbean'),
('gq', 'Equatorial Guinea', 'Africa'),
('gr', 'Greece', 'Europe'),
('gs', 'S. Georgia and S. Sandwich Isls.', 'Pacific'),
('gt', 'Guatemala', 'Central America'),
('gu', 'Guam', 'Pacific'),
('gw', 'Guinea-Bissau', 'Africa'),
('gy', 'Guyana', 'South America'),
('hk', 'Hong Kong', 'Asia'),
('hm', 'Heard and McDonald Islands', 'Australia'),
('hn', 'Honduras', 'Central America'),
('hr', 'Croatia (Hrvatska)', 'Europe'),
('ht', 'Haiti', 'Caribbean'),
('hu', 'Hungary', 'Europe'),
('id', 'Indonesia', 'Asia'),
('ie', 'Ireland', 'Europe'),
('il', 'Israel', 'Asia'),
('im', 'Isle of Man', 'Europe'),
('in', 'India', 'Asia'),
('io', 'British Indian Ocean Territory', 'Asia'),
('iq', 'Iraq', 'Asia'),
('ir', 'Iran', 'Asia'),
('is', 'Iceland', 'Europe'),
('it', 'Italy', 'Europe'),
('je', 'Jersey', 'Europe'),
('jm', 'Jamaica', 'Caribbean'),
('jo', 'Jordan', 'Asia'),
('jp', 'Japan', 'Asia'),
('ke', 'Kenya', 'Africa'),
('kg', 'Kyrgyzstan', 'Asia'),
('kh', 'Cambodia', 'Asia'),
('ki', 'Kiribati', 'Pacific'),
('km', 'Comoros', 'Asia'),
('kn', 'Saint Kitts and Nevis', 'Caribbean'),
('kp', 'Korea (North)', 'Asia'),
('kr', 'Korea (South)', 'Asia'),
('kw', 'Kuwait', 'Asia'),
('ky', 'Cayman Islands', 'Caribbean'),
('kz', 'Kazakhstan', 'Asia'),
('la', 'Lao People&#39;s Democratic Republic', 'Asia'),
('lb', 'Lebanon', 'Asia'),
('lc', 'Saint Lucia', 'Caribbean'),
('li', 'Liechtenstein', 'Europe'),
('lk', 'Sri Lanka', 'Asia'),
('lr', 'Liberia', 'Africa'),
('ls', 'Lesotho', 'Africa'),
('lt', 'Lithuania', 'Europe'),
('lu', 'Luxembourg', 'Europe'),
('lv', 'Latvia', 'Europe'),
('ly', 'Libyan Arab Jamahiriya', 'Africa'),
('ma', 'Morocco', 'Africa'),
('mc', 'Monaco', 'Europe'),
('md', 'Moldova', 'Europe'),
('me', 'Montenegro', 'Europe'),
('mf', 'Saint Martin', 'Caribbean'), -- 20120828
('mg', 'Madagascar', 'Asia'),
('mh', 'Marshall Islands', 'Pacific'),
('mk', 'Macedonia', 'Europe'),
('ml', 'Mali', 'Africa'),
('mm', 'Myanmar', 'Asia'),
('mn', 'Mongolia', 'Asia'),
('mo', 'Macau', 'Asia'),
('mp', 'Northern Mariana Islands', 'Pacific'),
('mq', 'Martinique', 'Caribbean'),
('mr', 'Mauritania', 'Africa'),
('ms', 'Montserrat', 'Caribbean'),
('mt', 'Malta', 'Europe'),
('mu', 'Mauritius', 'Asia'),
('mv', 'Maldives', 'Asia'),
('mw', 'Malawi', 'Africa'),
('mx', 'Mexico', 'Central America'),
('my', 'Malaysia', 'Asia'),
('mz', 'Mozambique', 'Africa'),
('na', 'Namibia', 'Africa'),
('nc', 'New Caledonia', 'Pacific'),
('ne', 'Niger', 'Africa'),
('nf', 'Norfolk Island', 'Australia'),
('ng', 'Nigeria', 'Africa'),
('ni', 'Nicaragua', 'Central America'),
('nl', 'Netherlands', 'Europe'),
('no', 'Norway', 'Europe'),
('np', 'Nepal', 'Asia'),
('nr', 'Nauru', 'Pacific'),
('nt', 'Neutral Zone', 'Asia'), -- not in 2015-06-06
('nu', 'Niue', 'Pacific'),
('nz', 'New Zealand (Aotearoa)', 'Australia'),
('om', 'Oman', 'Asia'),
('pa', 'Panama', 'Central America'),
('pe', 'Peru', 'South America'),
('pf', 'French Polynesia', 'Pacific'),
('pg', 'Papua New Guinea', 'Pacific'),
('ph', 'Philippines', 'Pacific'),
('pk', 'Pakistan', 'Asia'),
('pl', 'Poland', 'Europe'),
('pm', 'Saint Pierre and Miquelon', 'Caribbean'),
('pn', 'Pitcairn', 'Pacific'),
('pr', 'Puerto Rico', 'Caribbean'),
('ps', 'Palestinian Territory', 'Asia'),
('pt', 'Portugal', 'Europe'),
('pw', 'Palau', 'Pacific'),
('py', 'Paraguay', 'South America'),
('qa', 'Qatar', 'Asia'),
('re', 'Reunion', 'Pacific'),
('ro', 'Romania', 'Europe'),
('rs', 'Serbia', 'Europe'),
('ru', 'Russian Federation', 'Europe'),
('rw', 'Rwanda', 'Africa'),
('sa', 'Saudi Arabia', 'Asia'),
('sb', 'Solomon Islands', 'Pacific'),
('sc', 'Seychelles', 'Africa'),
('sd', 'Sudan', 'Africa'),
('se', 'Sweden', 'Europe'),
('sg', 'Singapore', 'Asia'),
('sh', 'St. Helena', 'Europe'),
('si', 'Slovenia', 'Europe'),
('sj', 'Svalbard and Jan Mayen Islands', 'Europe'),
('sk', 'Slovak Republic', 'Europe'),
('sl', 'Sierra Leone', 'Africa'),
('sm', 'San Marino', 'Europe'),
('sn', 'Senegal', 'Africa'),
('so', 'Somalia', 'Africa'),
('sr', 'Suriname', 'South America'),
('st', 'Sao Tome and Principe', 'Africa'),
('su', 'USSR (former)', 'Europe'),
('sv', 'El Salvador', 'Central America'),
('sx', 'Sint Maarten', 'Caribbean'), -- 20120828
('sy', 'Syrian Arab Republic', 'Asia'),
('sz', 'Swaziland', 'Africa'),
('tc', 'Turks and Caicos Islands', 'Caribbean'),
('td', 'Chad', 'Africa'),
('tf', 'French Southern Territories', 'Antarctica'),
('tg', 'Togo', 'Africa'),
('th', 'Thailand', 'Asia'),
('tj', 'Tajikistan', 'Asia'),
('tk', 'Tokelau', 'Australia'),
('tl', 'Timor-Leste', 'Asia'),
('tm', 'Turkmenistan', 'Asia'),
('tn', 'Tunisia', 'Africa'),
('to', 'Tonga', 'Africa'),
('tp', 'East Timor', 'Asia'), -- not in 2015-06-06
('tr', 'Turkey', 'Asia'),
('tt', 'Trinidad and Tobago', 'Cribbean'),
('tv', 'Tuvalu', 'Pacific'),
('tw', 'Taiwan', 'Asia'),
('tz', 'Tanzania', 'Africa'),
('ua', 'Ukraine', 'Europe'),
('ug', 'Uganda', 'Africa'),
('uk', 'United Kingdom', 'Europe'), -- not in 2015-06-06
('um', 'United States Minor Outlying Islands', 'Pacific'),
('us', 'United States', 'North America'),
('uy', 'Uruguay', 'South America'),
('uz', 'Uzbekistan', 'Asia'),
('va', 'Vatican City State (Holy See)', 'Europe'),
('vc', 'Saint Vincent and the Grenadines', 'Caribbean'),
('ve', 'Venezuela', 'South America'),
('vg', 'Virgin Islands (British)', 'Caribbean'),
('vi', 'Virgin Islands (U.S.)', 'Caribbean'),
('vn', 'Viet Nam', 'Asia'),
('vu', 'Vanuatu', 'Pacific'),
('wf', 'Wallis and Futuna Islands', 'Pacific'),
('ws', 'Samoa', 'Pacific'),
('xk', 'Kosovo','Europe'), -- 2015-06-06
('ye', 'Yemen', 'Asia'),
('yt', 'Mayotte', 'Asia'),
('yu', 'Yugoslavia', 'Europe'), -- not in 2015-06-06
('za', 'South Africa', 'Africa'),
('zm', 'Zambia', 'Africa'),
('zr', 'Zaire', 'Africa'),
('zw', 'Zimbabwe', 'Africa'),
--
('aero', 'air transport', 'aero'), -- 2010-08-07
('biz', 'business', 'biz'), -- 2010-08-07
('info', 'informational', 'info'), -- 2010-08-07
('name', 'families and individuals', 'name'), -- 2010-08-07
('pro', 'professions', 'pro'), -- 2010-08-07
('asia', 'Asia-Pacific', 'Asia'), -- 2010-08-07
('cat', 'Catalan', 'Europe'), -- 2010-08-07
('coop', 'Cooperatives', 'coop'), -- 2010-08-07
('jobs', 'HR', 'jobs'), -- 2010-08-07
('mobi', 'mobile', 'mobi'), -- 2010-08-07
('museum', 'Museums', 'museum'), -- 2010-08-07
('tel', 'telephone', 'tel'), -- 2010-08-07
('travel', 'travel', 'travel'), -- 2010-08-07
--
('numeric', 'Numeric', 'numeric'),
('arpa', 'ARPA', 'arpa'),
('gbl', 'Global', 'gbl'),
('eu', 'Europe unassigned', 'Europe'),
('com', 'world Commercial', 'com'),
('edu', 'US Educational', 'North America'),
('gov', 'US Government', 'North America'),
('int', 'International', 'int'),
('mil', 'US Military', 'North America'),
('net', 'Network', 'net'),
('org', 'Non-Profit Organization', 'org');

-- Classification of file extensions
DROP TABLE IF EXISTS wtsuffixclass;
CREATE TABLE wtsuffixclass(
 suf CHAR(8) PRIMARY KEY, -- file name suffix
 sufdetailsshort INT, -- 1 if files of this type should appear in visit details short
 sufdetailslong INT, -- 1 if files of this type should appear in visit details long
 sufclass CHAR(8) -- class for matching, values should have unique first letter
);
INSERT INTO wtsuffixclass (suf, sufdetailsshort, sufdetailslong, sufclass) VALUES
('html', 1, 1,'html'),
('htm', 1, 1,'html'),
('cgi', 1, 1,'html'),
('shtml', 1, 1,'html'),
('asp', 1, 1,'html'),
('php', 1, 1,'html'),
('html-ssi', 1, 1,'html'),
('htmi', 1, 1,'html'), -- when dash.cgi reads in remote htmi files prepared by webtrax
('gif', 0, 0,'graphic'),
('jpg', 0, 0,'graphic'),
('jpeg', 0, 0,'graphic'),
('png', 0, 0,'graphic'),
('svg', 0, 0,'graphic'), -- 2016-03-25, used at SRS
('ttf', 0, 0, 'graphic'), -- 20160410, made invisible 20161027
('woff', 0, 0, 'graphic'), -- 20160410, made invisible 20161027
('woff2', 0, 0, 'graphic'), -- 20160410, made invisible 20161027
('eot', 0, 0, 'graphic'), -- 20160410, made invisible 20161027
('js', 0, 0,'css'), -- 2012-11-14, multics redesign pulls in 2 .js files
('swf', 1, 1,'swf'),
('css', 0, 0,'css'),
('exe', 1, 1,'dl'),
('zip', 1, 1,'dl'),
('z', 1, 1,'dl'),
('hqx', 1, 1,'dl'),
('sit', 1, 1,'dl'),
('pdf', 1, 1,'dl'), -- i wonder if this should be html nowadays
('au', 1, 1,'snd'),
('mp2', 1, 1,'snd'),
('mp3', 1, 1,'snd'),
('snd', 1, 1,'snd'),
('wav', 1, 1,'snd'),
('class', 1, 1,'Java'),
('jar', 1, 1,'Java'),
('c', 1, 1,'src'),
('h', 1, 1,'src'),
('makefile', 1, 1,'src'),
('make', 1, 1,'src'),
('java', 1, 1,'src'),
('cpp', 1, 1,'src'),
('pl', 1, 1,'src'),
('pl1', 1, 1,'src'), -- 20181007
('mixal', 1, 1,'src'), -- 20181007
('ec', 1, 1,'src'), -- 20181007
('runoff', 1, 1,'src'), -- 20181007
('calin', 1, 1,'src'), -- 20181007
('alm', 1, 1,'src'), -- 20181007
('manifest', 1, 1,'src'), -- new 20121015
('txt', 1, 1, 'text'),
('xml', 1, 1, 'xml'),
('bin', 1, 1, 'dl'),
('doc', 1, 1, 'dl'),
('docx', 1, 1, 'dl'),
('xls', 1, 1, 'dl'),
('xlsx', 1, 1, 'dl'),
('ai', 1, 1, 'dl'),
('ps', 1, 1, 'dl'),
('psd', 1, 1, 'dl'),
('ppt', 1, 1, 'dl'),
('pptx', 1, 1, 'dl'),
('dot', 1, 1, 'dl'), -- ambiguous, could be graphviz or MSWord template
('dmg', 1, 1, 'dl'),
('tgz', 1, 1, 'dl'),
('gz', 1, 1, 'dl'),
('img', 1, 1, 'dl'),
('dat', 1, 1, 'dl'), -- 20160410
('po', 1, 1, 'dl'), -- 20160410
('do', 1, 1, 'dl'), -- 20160410
('com', 1, 1, 'dl'), -- 20160410
('mov', 1, 1, 'video'),
('wma', 1, 1, 'video'),
('qt', 1, 1, 'video'),
('real', 1, 1, 'snd'),
('tif', 1, 1, 'graphic'),
('tiff', 1, 1, 'graphic'),
('ico', 0, 0, 'graphic'),
('', 1, 1, 'blank');

-- ================================================================
-- some graphics should be shown if they are in a particular dir and referrer
-- slashes in regexps must be preceded by two backslashes .. SQL leaves one, rexp unspecials the slash
-- printvisitdetail loads this table into a hash for speed
DROP TABLE IF EXISTS wtshowanyway;
CREATE TABLE wtshowanyway(
 referrer VARCHAR(255), -- referrer, specify with www and without will be done also
 pathrexp VARCHAR(255) -- matched against path name, regexp, escape slashes
);
-- remember if the referrer is index.html to also put just dirname/
-- INSERT INTO wtshowanyway (referrer, pathrexp) VALUES
-- ('http://www.a.b/our-trip/index.html','^\\/subdir\\/images/'),
-- ('http://www.a.b/our-trip/','^\\/subdir\\/images/');

-- ================================================================
-- ---- global constants and configuration.
-- ================================================================
-- defaults for user tailorable items -- overrides in ./swt-user.sql
-- these items are written out into wtglobalvalues.sh and loaded into the environment, where expandfile uses them
DROP TABLE IF EXISTS wtglobalvalues;
CREATE TABLE wtglobalvalues(
 gloname varchar(32) PRIMARY KEY, -- report name and name anchor
 glovalue VARCHAR(1023), -- value
 glocomm VARCHAR(1023) -- documentation, blank if not interesting to user
);
INSERT INTO wtglobalvalues (gloname, glovalue, glocomm) VALUES
('sitename','User Website','Title for the usage report'), -- expected that user will override this
('siteid','User','Short name for the dashboard'), -- expected that user will override this
('returnurl','index.html','URL of user website, for return link'),
-- standard machinery, user can override
-- this is one way that users can enhance the report, by creating a pre or postamble file with a cron job.
('preamble','','File copied at top of report'),
('postamble','','File copied at bottom of report'),
-- pathnames in your shell account.. $HOME will get expanded
('CONFIGFILE','swtconfig.htmi','Pathname of database configuration file -- should be mode 400, has database password'),
('PROGRAMDIR','$HOME/swt','Directory where templates are installed .. can be overridden by swt-user.sql'),
('DATADIR','$HOME/swt','Directory where data files are kept .. can be overridden by swt-user.sql'),
('TOOLSDIR','$HOME/swt/tools','Directory where data files are kept .. can be overridden by swt-user.sql'),
('CHECKSWTFILES','$HOME/swt/tools/checkswtfiles','script that makes sure files are present .. can be overridden by swt-user.sql'),
('REPORTDIR','$HOME/swt/live','where to move the output report .. shd be overridden by swt-user.sql'),
-- change this if visits have multiple referrers. 2 allows for users who link us from their blog and test it.
('visitdata_refspamthresh','2','more than this many different referrers in one visit is spamsign'),
-- if the wtdomhist table gets enormous, trim it back to ~90 days.  history older than that is probably not important.
('ndomhistdays','366','number of days to keep in wtdomhist table'),
-- if the wtcumquery table gets enormous, trim it back by discarding the rarest queries.
('cumquerycntmin','2','min number of queries to keep query in wtcumquery table'),
('cumquerybytemin','2500','min number of bytes to keep query in wtcumquery table'),
-- bandwidth quota
('gbquota','0','bandwidth quota in GB for this account'),
-- .. pair networks drops the highest day of the month in its bandwidth calc
('gbquotadrophighest','N','Y to drop the highest day of the month in the bandwidth calculation'),
-- file names
('OUTPUTFILE','swtreport.html','name of output report'),
('DASHFILE','swtdash.csv','name of output dashboard report'),
('IMPORTANTFILE','important.html','name of last-7-days report'),
('IMPORTANT','important','component name of output important visits report'),
('PATHSFILE','paths.dot','name of output paths report'),
('stylesheet','swtstyle.css','name of style sheet'),
-- formatting of graphs
('glb_bar_graph_width','500','width in pixels of horizontal bar graph'),
('glb_bar_graph_height','10','height of a bar in horiz graph, also width of bar in vertical graph'),
-- .. Pie chart applet params
('java_enabled','y',''),  -- is this obsolete
('pieappletcode','Pie.class',''),  -- is this obsolete
('pieappletwidth','260','Width of pie chart'), -- was 300wx350h
('pieappletheight','220','Height of pie chart'),
('pieappletextra','',''), -- two backslashes before quotes, e.g. 'codebase=\\"https://www.x.y.x/\\"'  -- is this obsolete
-- Unix command coupling
-- .. expandfile has to be on the PATH even for a cron job .. expandfile.pm, thvvutil.pm, readapacheline.pm must be on the Perl lib path
('EXPAND','./tools/expandfile','Template expander command'),
-- used in loadusage()
('LOGVISITS','perl ./tools/logvisits3.pl','perl prog'),
('VISITDATA','perl ./tools/visitdata3.pl','perl prog'),
('WORDLIST','perl ./tools/wordlist3.pl','perl prog'),
-- used in detailsrep()
('PRINTVISITDETAIL','perl ./tools/printvisitdetail3.pl','perl prog'),
-- .. override these commands to produce output if debugging
('COMMANDPREFIX','nice','Prefix commands with this command, can be "nice" or null'),
('CLEANUP','rm','File deletion command. For debugging, change rm to echo'),
('ECHO','echo','change to "true" to shut program up'),
('MYSQLLOAD','./tools/mysqlload','invoke mysql to source a file, contains password, must match config file, mode 500'),
('MYSQLRUN','./tools/mysqlrun','invoke mysql for one command, contains password, must match config file, mode 500'),
('MYSQLDUMPCUM','./tools/mysqldumpcum','how to invoke mysqldump, contains password, must match config file, mode 500'),
-- distribution information
('wtversion','S24','version of this program for selecting help file'),
('urlbase','http://www.multicians.org/thvv/','Absolute URL prefix to live help'),
-- Constants
-- .. arithmetic facts
('bytes2mb','1048576',''),
('bytes2gb','1073741824',''),
-- .. used when doing double expansion
('pct','%',''),
('lbkt','[',''),
('rbkt',']','');

-- Reports, one entry per report
-- .. there are also some other "non report" activities in this table
-- these items are written out into wtglobalvalues.sh and loaded into the environment
DROP TABLE IF EXISTS wtreports;
CREATE TABLE wtreports(
 reportid varchar(32) PRIMARY KEY, -- report name and name anchor
 repshort VARCHAR(32), -- short ID of report for navbar
 repname VARCHAR(1023), -- long explanation of report for TITLE attribute
 repcomm VARCHAR(1023), -- comments
 repord FLOAT -- 0 if not on navbar, otherwise order in navbar
);
INSERT INTO wtreports (reportid, repshort, repname, repcomm, repord) VALUES
('clean_hits','','Clean out junk from hits table','Remove PYCurl hits for referrer spam',0.0),
('visitdata','','Generate visits table from hits table','',0.0),
('update_wtdayhist','','Add a row to the daily history','',0.0),
('rpt_heading','top','Heading','Queries for global totals used in multiple reports',0.0),
('rpt_summary','Month','Month Summary','Usage by day for the last month, and comparson of usage to yesterday, week ago, and month average',1.0),
('rpt_pie2','Pie','Pie Charts','Pie charts summarizing usage',2.0),
('rpt_analysis','Analysis','Analysis','Table summarizing usage totals',3.0),
('rpt_dash','dash','Dashboard','',0.0),
('rpt_html','HTML','HTML pages','Report of hits on HTML pages with horizontal bar chart striped by hit source',4.0),
('rpt_graphics','Graphics','Graphic files','Report of hits on graphic files with horizontal bar chart striped by hit source',5.0),
('rpt_css','CSS','CSS files','Report of hits on css files with horizontal bar chart striped by hit source',6.0),
('rpt_flash','Flash','Flash files','Report of hits on flash files with horizontal bar chart striped by hit source',7.0),
('rpt_dl','Down','Files Downloaded','Report of hits on binary download files with horizontal bar chart striped by hit source',8.0),
('rpt_snd','Snd','Sound files','Report of hits on sound files with horizontal bar chart striped by hit source',9.0),
('rpt_xml','XML','XML files','Report of hits on XML files with horizontal bar chart striped by hit source',10.0),
('rpt_java','Java','Java Class files','Report of hits on Java Class files with horizontal bar chart striped by hit source',11.0),
('rpt_src','Source','Source files','Report of hits on source files with horizontal bar chart striped by hit source',12.0),
('rpt_other','Other','Other files','Report of hits on other files with horizontal bar chart striped by hit source',13.0),
('rpt_fnf','404','Files not found','Report of attempts to access nonexistent files',14.0),
('rpt_403','403','Forbidden transactions','Table showing attempts to access files denied by .htaccess restriction',15.0),
('rpt_illref','Illref','Illegal referrers','Report showing non-HTML files not referred by a local HTML file with horizontal bar chart',16.0),
('rpt_accesstime','Time','Hits by access time','Vertical bar chart: hits by access time, striped by html/graphic/other',17.0),
('rpt_duration','Duration','NI Visits by duration','Report of non-indexer visits ordered by estimated duration with horizontal bar chart',18.0),
('rpt_nhits','Nhits','NI Visits by number of hits','Report of non-indexer visits ordered by number of hits',19.0),
('rpt_nviews','Nviews','NI Visits by number of page views','Report of non-indexer visits ordered by number of page views',20.0),
('rpt_domain','Visitors','Visitors','Report of visits by domain with horizontal bar chart striped by visit class',21.0),
('rpt_tld','TLD','Visits by Top Level Domain','Report of visits by toplevel domain with horizontal bar chart striped by visit class',22.0),
('rpt_domain2','2LD','Visits by Second Level Domain','Report of visits by second level domain with horizontal bar chart striped by visit class',23.0),
('rpt_domain3','3LD','Visits by Third Level Domain','Report of visits by third level domain with horizontal bar chart striped by file type',24.0),
('rpt_geoloc','City','Visits by City','Report of non-indexer visits by city with horizontal bar chart striped by visit class',24.2),
('rpt_authid','Authid','Visits by Authenticated Users','Report of visits by username used to authenticate with horizontal bar chart striped by file type',24.4),
('rpt_class','Class','Visits by Class','Report of hits by class, striped by source',25.0),
('rpt_browser','Browser','Hits by Browser','Report of hits by browser, striped by visit class',26.0),
('rpt_query','Query','Hits by Query','Report of hits by query with horizontal bar chart',27.0),
('rpt_day_words','Words','Word Usage in Queries','Report of words in queries with horizontal bar chart',27.5),
('rpt_engine','Engine','Visits by Search Engine','Report of hits by search engine with horizontal bar chart',28.0),
('rpt_google','Google','Files Crawled by Google','Report of files crawled by Google showing time',28.5),
('rpt_referrer','Referrer','Hits by Referrer','Report of hits by referrer with horizontal bar chart',29.0),
('rpt_referrerdom','RefDom','Hits by Referring Domain','Report of hits by referring domain with horizontal bar chart',29.0),
('rpt_filesize','Size','Number of Hits by file size','Report of hits by file size with horizontal bar chart',30.0),
('rpt_localquery','Local','Hits by Local Query','Report of hits by local query with horizontal bar chart',31.0),
('rpt_repeat','Repeat','Repeated Hits by Domain','Report of repeated hits by domain with horizontal bar chart',31.4),
('rpt_attacks','Attacks','Attacks on the site','Table showing various attacks on the site',32.0),
('rpt_retcode','Retcode','Transactions by server return code','Table of transactions by return code',33.0),
('rpt_verb','Verb','Transactions by protocol verb','Table of transactions by protocol verb',34.0),
('rpt_day7','day7','Last 7 days Important visit details','Listing of HTML files accessed in each visit by time',0.0),
('rpt_details','Details','Visit Details','Listing of HTML files accessed in each visit by time',35.0),
('update_wtcumquery','','','',0.0),
('update_wtcumref','','','',0.0),
('update_wtdomhist','','','',0.0),
('update_wtcumfile','','','',0.0),
('update_wtfilehist','','','',0.0), -- this is obsolete, replaced by wtcumfile
('update_wtcumgoog','','','',0.0),
('trim_wtdomhist','','Trim wtdomhist table to a given number of days','',0.0),
('trim_wtcumquery','','Trim wtcumquery table rarest queries','',0.0),
('rpt_year_referrer','yReferrer','Cumulative Non-search Hits by Referrer Domain','Report of cumulative hits by referring domain with horizontal bar chart',36.0),
('rpt_year_query','yQuery','Cumulative Hits by Query','Report of cumulative hits by query with horizontal bar chart',37.0),
('rpt_year_domain','yDomain','Cumulative hits by visitor','Report of cumulative hits by visitor with horizontal bar chart',38.0),
('rpt_dslv_domain','DSLV','Visitors by days since last visit','Report of number of visitors by days since last visit with horizontal bar chart',39.0),
('rpt_year_words','yWords','Cumulative Query Word Usage','Report of cumulative words in queries with horizontal bar chart',39.5),
('rpt_byyear','ByYear','Traffic by year','Report traffic by year with horizontal bar chart',40.0),
('rpt_cumpage','yPage','Cumulative hits on HTML Pages','Report of cumulative hits by HTML page with horizontal bar chart',41.0),
('rpt_bymonth','Bymonth','Hits by month','Vertical bar chart of hits by month striped by html/graphic/other',42.0),
('rpt_paths','Paths','Paths through the site','',0.0);

-- report option values
-- every report is enabled by default
DROP TABLE IF EXISTS wtreportoptions;
CREATE TABLE wtreportoptions(
 optid varchar(32), -- report name and name anchor
 optname VARCHAR(255), -- attribute
 optvalue VARCHAR(1023), -- value
 optdoc VARCHAR(1023), -- documentation, blank if user is not expected to change this
 PRIMARY KEY(optid, optname)
);
INSERT INTO wtreportoptions (optid, optname, optvalue, optdoc) VALUES
('rpt_403','bytetotalvar','.filebytes',''),
('rpt_403','bytevar','.bytes',''),
('rpt_403','enabled','y','y if this report is enabled'),
('rpt_403','filetotalvar','.filecount',''),
('rpt_403','hitcountvar','.hitcount',''),
('rpt_403','hittotalvar','.filehits',''),
('rpt_403','labelvar1','hits.path',''),
('rpt_403','labelvar2','hits.referrerurl',''),
('rpt_403','template','report403.htmt',''),
('rpt_403','top','10','number of entries to show'),
('rpt_accesstime','bytesvar','.bytes',''),
('rpt_accesstime','enabled','y','y if this report is enabled'),
('rpt_accesstime','graph_height','144','height of graph for this report'),
('rpt_accesstime','hhvar','.hh',''),
('rpt_accesstime','hitcountvar','.hitcount',''),
('rpt_accesstime','maxhitsvar','.busy',''),
('rpt_accesstime','template','accesstime.htmt',''),
('rpt_accesstime','xgvar','.xg',''),
('rpt_accesstime','xxvar','.xx',''),
('rpt_analysis','enabled','y','y if this report is enabled'),
('rpt_analysis','template','analysis.htmt',''),
('rpt_attacks','enabled','y','y if this report is enabled'),
('rpt_attacks','timevar','.tim',''), -- query1, query2, query3
('rpt_attacks','domainvar','hits.domain',''), -- all
('rpt_attacks','pathvar','.hitp',''), -- query1, query2, query3
('rpt_attacks','retcodevar','hits.retcode',''), -- all
('rpt_attacks','nhitsvar','.nhit',''), -- query3 groups by domain
('rpt_attacks','hitsvar','.nhit',''), -- query4
('rpt_attacks','filenamevar','.hitfile',''), -- query4
('rpt_attacks','template','attacks.htmt',''),
('rpt_attacks','watch','','list of CGIs that may be attacked by hackers, default none'),
('rpt_attacks','watchuse','','list of files whose excessive use is tracked, default none'),
('rpt_attacks','watchuselimit','5','number of uses that is excessive'),
('rpt_attacks','top','10','number of entries to show'),
('rpt_browser','col0head','%[nbrowser]% Browsers',''),
('rpt_browser','col0v','nbrowser',''),
('rpt_browser','col0h','Browsers',''),
('rpt_browser','col1s','1',''),
('rpt_browser','col1t','Visits',''),
('rpt_browser','col1tv','totalvisits',''),
('rpt_browser','col1v','x.vno',''),
('rpt_browser','col2s','1024',''),
('rpt_browser','col2t','KB',''),
('rpt_browser','col2tv','totalkb',''),
('rpt_browser','col2v','x.bytes',''),
('rpt_browser','col3maxv','.m',''),
('rpt_browser','col3s','1',''),
('rpt_browser','col3t','hits',''),
('rpt_browser','col3tv','totalhits',''),
('rpt_browser','col3v','x.hitcount',''),
('rpt_browser','enabled','y','y if this report is enabled'),
('rpt_browser','expvar','.xid',''),
('rpt_browser','labelvar','visits.browsername',''),
('rpt_browser','labelvar2','visits.platformtype',''),
('rpt_browser','legendcolor','wtvclasses.vbarcolor',''),
('rpt_browser','legendname','wtvclasses.vclass',''),
('rpt_browser','stripecolor','wtvclasses.vbarcolor',''),
('rpt_browser','stripecount','.hcvc',''),
('rpt_browser','template','histo3nn1.htmt',''),
('rpt_browser','top','20','number of entries to show'),
('rpt_bymonth','bytesvar','.b',''),
('rpt_bymonth','enabled','y','y if this report is enabled'),
('rpt_bymonth','graph_height','144',''),
('rpt_bymonth','graphichitsvar','.hg',''),
('rpt_bymonth','hitsvar','.h',''),
('rpt_bymonth','htmlhitsvar','.hh',''),
('rpt_bymonth','maxhitsvar','.mx',''),
('rpt_bymonth','monthvar','.m',''),
('rpt_bymonth','template','vhisto.htmt',''),
('rpt_bymonth','visitsvar','.v',''),
('rpt_class','col0head','%[nvisitclass]% Visit Classes',''),
('rpt_class','col0v','nvisitclass',''),
('rpt_class','col0h','Visit Classes',''),
('rpt_class','col1s','1',''),
('rpt_class','col1t','Visits',''),
('rpt_class','col1tv','totalvisits',''),
('rpt_class','col1v','x.vno',''),
('rpt_class','col2s','1024',''),
('rpt_class','col2t','KB',''),
('rpt_class','col2tv','totalkb',''),
('rpt_class','col2v','x.bytes',''),
('rpt_class','col3maxv','.m',''),
('rpt_class','col3s','1',''),
('rpt_class','col3t','hits',''),
('rpt_class','col3tv','totalhits',''),
('rpt_class','col3v','x.hitcount',''),
('rpt_class','enabled','y','y if this report is enabled'),
('rpt_class','labelvar','visits.visitclass',''),
('rpt_class','legendcolor','wtvsources.sourcecolor',''),
('rpt_class','legendname','wtvsources.sourceid',''),
('rpt_class','stripecolor','wtvsources.sourcecolor',''),
('rpt_class','stripecount','.hcvc',''),
('rpt_class','template','histo3n1.htmt',''),
('rpt_css','bytetotalvar','.filebytes',''),
('rpt_css','bytevar','x.bytes',''),
('rpt_css','enabled','y','y if this report is enabled'),
('rpt_css','filetotalvar','.filecount',''),
('rpt_css','hitcountvar','x.hitcount',''),
('rpt_css','hittotalvar','.filehits',''),
('rpt_css','labelvar','hits.path',''),
('rpt_css','legendcolor','wtvsources.sourcecolor',''),
('rpt_css','legendname','wtvsources.sourceid',''),
('rpt_css','stackcolor','wtvsources.sourcecolor',''),
('rpt_css','stackvar','.hcvc',''),
('rpt_css','template','filetype1.htmt',''),
('rpt_css','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_css','top','','number of lines to show'),
('rpt_cumpage','col0head','%[yhfile]% HTML Files',''),
('rpt_cumpage','col0v','yhfile',''),
('rpt_cumpage','col0h','HTML Files',''),
('rpt_cumpage','col1s','1048576',''),
('rpt_cumpage','col1t','MB',''),
('rpt_cumpage','col1tv','yhtotalbytes',''),
('rpt_cumpage','col1v','.bytes',''),
('rpt_cumpage','col2s','1',''),
('rpt_cumpage','col2t','hits',''),
('rpt_cumpage','col2tv','yhtotalhits',''),
('rpt_cumpage','col2v','wtcumfile.ffilecnt',''),
('rpt_cumpage','enabled','y','y if this report is enabled'),
('rpt_cumpage','labelv','wtcumfile.ffilename',''),
('rpt_cumpage','labelclassv','wtcolors.colorclass',''),
('rpt_cumpage','template','cumpage.htmt',''),
('rpt_cumpage','top','20','number of entries to show'),
('rpt_byyear','labelt','Year',''), -- 2010-11-26
('rpt_byyear','labelvar','.cumyear',''),
('rpt_byyear','col1s','1',''),
('rpt_byyear','col1t','visits',''),
('rpt_byyear','col1tv','.cumtvisits',''), -- q2
('rpt_byyear','col1v','.cumvisits',''),
('rpt_byyear','col2s','1048576',''), --
('rpt_byyear','col2t','MB',''), --
('rpt_byyear','col2tv','.cumtbytes',''), -- q2
('rpt_byyear','col2v','.cumbytes',''),
('rpt_byyear','col3s','1',''),
('rpt_byyear','col3t','hits',''),
('rpt_byyear','col3tv','.cumthits',''), -- q2
('rpt_byyear','col3v','.cumhits',''),
('rpt_byyear','col3hv','.cumhtmlpages',''),
('rpt_byyear','col3gv','.cumgraphicpages',''),
('rpt_byyear','col3maxv','.hitscale',''), -- q3
('rpt_byyear','enabled','y','y if this report is enabled'),
('rpt_byyear','template','byyear.htmt',''),
('rpt_dash','enabled','y','y if this report is enabled'),
('rpt_dash','template','dashcsv.htmt',''),
('rpt_day7','enabled','y','y if this report is enabled'),
('rpt_day7','template','importantwrapper.htmt',''),
('rpt_details','enabled','y','y if this report is enabled'),
('rpt_details','eventlogfile','','filename for event log, blank if none'),
('rpt_details','longclass','details',''),
-- do not put quote marks in criteria, causes printvisitdetail to fail.
-- report criteria, see printvisitdetail .. sets "print" to 1 or 0
('rpt_details','longcriteria','%[*set,&print,=0]%%[*if,ge,pagesinvisit,=1,*set,&print,=1]%','criteria executed by printvisitdetail to decide whether to add a visit to long report'),
('rpt_details','shortclass','details',''),
('rpt_details','subsubtitle','show/hide indexers',''),
-- report criteria, see printvisitdetail: can ref hitsinvisit,pagesinvisit,visitgoodpages,visit404pages,bytesinvisit,alarm,browser,vclass,source,authid,newdomain,wtcolorfiles,newreferrers
-- default short criteria says: show new referrer, page in color, not indexers/refspam/boring/nohtml, not if mostly 404
('rpt_details','shortcriteria','%[*set,&print,=0]%%[*if,ge,newreferrers,=1,*set,&print,=1]%%[*if,ge,wtcolorfiles,=1,*set,&print,=1]%%[*if,eq,vclass,=indexer,*set,&print,=0]%%[*if,eq,source,=refspam,*set,&print,=0]%%[*if,ge,boring,pagesinvisit,*set,&print,=0]%%[*if,ge,visit404pages,visitgoodpages,*set,&print,=0]%','criteria executed by printvisitdetail to decide whether to add a visit to short report'),
-- could use *if,=~,logtext,"something" to test whether to set logprint
('rpt_details','longlogcriteria','%[*set,&logprint,=1]%','criteria executed by printvisitdetail to decide whether to add a log entry to long report'),
('rpt_details','shortlogcriteria','%[*set,&logprint,=0]%','criteria executed by printvisitdetail to decide whether to add a log entry to short report'),
('rpt_details','showdirs','0','1 to show directory names as well as filenames'),
('rpt_details','stclass','x',''),
('rpt_details','template','longshort.htmt',''),
('rpt_dl','bytetotalvar','.filebytes',''),
('rpt_dl','bytevar','x.bytes',''),
('rpt_dl','enabled','y','y if this report is enabled'),
('rpt_dl','filetotalvar','.filecount',''),
('rpt_dl','hitcountvar','x.hitcount',''),
('rpt_dl','hittotalvar','.filehits',''),
('rpt_dl','labelvar','hits.path',''),
('rpt_dl','legendcolor','wtvsources.sourcecolor',''),
('rpt_dl','legendname','wtvsources.sourceid',''),
('rpt_dl','stackcolor','wtvsources.sourcecolor',''),
('rpt_dl','stackvar','.hcvc',''),
('rpt_dl','template','filetype1.htmt',''),
('rpt_dl','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_dl','top','','number of lines to show'),
('rpt_domain','col1s','1',''),
('rpt_domain','col1t','Visits',''),
('rpt_domain','col1v','x.vno',''),
('rpt_domain','col1tv','totalvisits',''),
('rpt_domain','col1tx','Visits Today',''),
('rpt_domain','col2s','1024',''),
('rpt_domain','col2t','KB',''),
('rpt_domain','col2v','x.bytes',''),
('rpt_domain','col2tv','totalkb',''),
('rpt_domain','col2tx','KB Today',''),
('rpt_domain','col3maxv','.m',''),
('rpt_domain','col3s','1',''),
('rpt_domain','col3t','hits',''),
('rpt_domain','col3v','x.hitcount',''),
('rpt_domain','col3tv','totalhits',''),
('rpt_domain','col3tx','Hits Today',''),
('rpt_domain','col4s','1',''),
('rpt_domain','col4t','DSPV',''),
('rpt_domain','col4v','.dspv',''), -- 20180610
('rpt_domain','col4tv','',''),
('rpt_domain','col4tx','Days Since Previous Visit',''),
('rpt_domain','enabled','y','y if this report is enabled'),
('rpt_domain','labelvar','visits.vdomain',''),
('rpt_domain','legendcolor','wtvclasses.vbarcolor',''),
('rpt_domain','legendname','wtvclasses.vclass',''),
('rpt_domain','newdomain','.dhd',''), -- 20180610
('rpt_domain','stripecolor','wtvclasses.vbarcolor',''),
('rpt_domain','stripecount','.hcvc',''),
('rpt_domain','template','domain1.htmt',''),
('rpt_domain','top','20','number of entries to show'),
-- ('rpt_domain','start','long','long=start with long report'), -- this is how you enable starting a report unhidden
('rpt_domain2','col1t','Visits',''),
('rpt_domain2','col1tv','totalvisits',''),
('rpt_domain2','col1v','.nv',''),
('rpt_domain2','col2s','1024',''),
('rpt_domain2','col2t','KB',''),
('rpt_domain2','col2tv','totalkb',''),
('rpt_domain2','col2v','.bytes',''),
('rpt_domain2','col3gv','.g',''),
('rpt_domain2','col3hv','.h',''),
('rpt_domain2','col3maxv','.m',''),
('rpt_domain2','col3t','Hits',''),
('rpt_domain2','col3tv','totalhits',''),
('rpt_domain2','col3v','.hits',''),
('rpt_domain2','enabled','y','y if this report is enabled'),
('rpt_domain2','labelt','2d level dom',''),
('rpt_domain2','labelvar','visits.ttld',''),
('rpt_domain2','template','domainlevel.htmt',''),
('rpt_domain2','top','20','number of entries to show'),
('rpt_domain2','totalv','ndomainstoday',''),
('rpt_domain2','totalvt','domains',''),
('rpt_domain2','restrict','',''),
('rpt_domain3','col1t','Visits',''),
('rpt_domain3','col1tv','totalvisits',''),
('rpt_domain3','col1v','.nv',''),
('rpt_domain3','col2s','1024',''),
('rpt_domain3','col2t','KB',''),
('rpt_domain3','col2tv','totalkb',''),
('rpt_domain3','col2v','.bytes',''),
('rpt_domain3','col3gv','.g',''),
('rpt_domain3','col3hv','.h',''),
('rpt_domain3','col3maxv','.m',''),
('rpt_domain3','col3t','Hits',''),
('rpt_domain3','col3tv','totalhits',''),
('rpt_domain3','col3v','.hits',''),
('rpt_domain3','enabled','y','y if this report is enabled'),
('rpt_domain3','labelt','3d level dom',''),
('rpt_domain3','labelvar','visits.tttld',''),
('rpt_domain3','template','domainlevel.htmt',''),
('rpt_domain3','top','20','number of entries to show'),
('rpt_domain3','totalv','ndomainstoday',''),
('rpt_domain3','totalvt','domains',''),
('rpt_domain3','restrict','',''),
('rpt_authid','col1t','Visits',''),
('rpt_authid','col1tv','totalauthsess',''),
('rpt_authid','col1v','.nv',''),
('rpt_authid','col2s','1024',''),
('rpt_authid','col2t','KB',''),
('rpt_authid','col2tv','totalauthkb',''),
('rpt_authid','col2v','.bytes',''),
('rpt_authid','col3gv','.g',''),
('rpt_authid','col3hv','.h',''),
('rpt_authid','col3maxv','.m',''),
('rpt_authid','col3t','Hits',''),
('rpt_authid','col3tv','totalauthhits',''),
('rpt_authid','col3v','.hits',''),
('rpt_authid','enabled','n','y if this report is enabled'), -- default no
('rpt_authid','labelt','User ID',''),
('rpt_authid','labelvar','visits.authid',''),
('rpt_authid','template','domainlevel.htmt',''),
('rpt_authid','totalv','totalauthids',''),
('rpt_authid','totalvt','authIDs',''),
('rpt_authid','restrict',' WHERE authid != \'\'','empty if you want to include unauthorized sessions'),
('rpt_authid','top','','number of entries to show'), -- default is to show all
('rpt_dslv_domain','col1t','DSLV',''),
('rpt_dslv_domain','col1v','x.dslv',''),
('rpt_dslv_domain','col2max','.maxdoms',''),
('rpt_dslv_domain','col2t','Visitors',''),
('rpt_dslv_domain','col2tv','ydd',''),
('rpt_dslv_domain','col2v','.ndoms',''),
('rpt_dslv_domain','enabled','y','y if this report is enabled'),
('rpt_dslv_domain','template','dslvhist.htmt',''),
('rpt_dslv_domain','top','20','number of entries to show'),
('rpt_duration','bartitle','visits.visitclass',''),
('rpt_duration','col1s','1',''),
('rpt_duration','col1t','Hits',''),
('rpt_duration','col1tv','totalhitsni',''),
('rpt_duration','col1v','visits.ninvisit',''),
('rpt_duration','col2s','1',''),
('rpt_duration','col2t','HTML',''),
('rpt_duration','col2tv','htmlhitsni',''),
('rpt_duration','col2v','visits.htmlinvisit',''),
('rpt_duration','col3s','1024',''),
('rpt_duration','col3t','KB',''),
('rpt_duration','col3tv','totalkbni',''),
('rpt_duration','col3v','visits.bytesinvisit',''),
('rpt_duration','col4t','Duration',''),
('rpt_duration','col4tv','',''),
('rpt_duration','col4v','visits.duration',''),
('rpt_duration','enabled','y','y if this report is enabled'),
('rpt_duration','label1t','Non-indexer Visitors',''),
('rpt_duration','label1tv','ndomainstoday',''),
('rpt_duration','label1var','visits.vdomain',''),
('rpt_duration','legendcolor','wtvclasses.vbarcolor',''),
('rpt_duration','legendname','wtvclasses.vclass',''),
('rpt_duration','rowcolor','wtvclasses.vbarcolor',''),
('rpt_duration','template','duration.htmt',''),
('rpt_duration','top','10','number of entries to show'),
('rpt_engine','col0head','%[nengine]% Engines',''),
('rpt_engine','col0v','nengine',''),
('rpt_engine','col0h','Engines',''),
('rpt_engine','col1s','1024',''),
('rpt_engine','col1t','KB',''),
('rpt_engine','col1tv','.tqb',''),
('rpt_engine','col1v','.bytes',''),
('rpt_engine','col2s','1',''),
('rpt_engine','col2t','hits',''),
('rpt_engine','col2tv','.tqh',''),
('rpt_engine','col2v','.hitcount',''),
('rpt_engine','colflag','.imageflag',''),
('rpt_engine','enabled','y','y if this report is enabled'),
('rpt_engine','labelvar','hits.referrerurl',''),
('rpt_engine','template','queries.htmt',''),
('rpt_engine','top','30','number of entries to show'),
('rpt_google','pathvar','hits.path',''),
('rpt_google','sizevar','hits.txsize',''),
('rpt_google','datevar','.lgdate',''),
('rpt_google','enabled','y','y if this report is enabled'),
('rpt_google','template','google.htmt',''),
('rpt_google','top','10','number of entries to show'),
('rpt_filesize','col1t','size (bytes)',''),
('rpt_filesize','col1v','.b',''),
('rpt_filesize','col2s','1024',''),
('rpt_filesize','col2t','KB',''),
('rpt_filesize','col2v','.c',''),
('rpt_filesize','col3t','hits',''),
('rpt_filesize','col3v','.a',''),
('rpt_filesize','enabled','y','y if this report is enabled'),
('rpt_filesize','newrefvar','wtcumref.refurl',''),
('rpt_filesize','template','filesize.htmt',''),
('rpt_filesize','totv','.f',''),
('rpt_filesize','watchvar','wtreferrercolor.rcclass',''),
('rpt_flash','bytetotalvar','.filebytes',''),
('rpt_flash','bytevar','x.bytes',''),
('rpt_flash','enabled','y','y if this report is enabled'),
('rpt_flash','filetotalvar','.filecount',''),
('rpt_flash','hitcountvar','x.hitcount',''),
('rpt_flash','hittotalvar','.filehits',''),
('rpt_flash','labelvar','hits.path',''),
('rpt_flash','legendcolor','wtvsources.sourcecolor',''),
('rpt_flash','legendname','wtvsources.sourceid',''),
('rpt_flash','stackcolor','wtvsources.sourcecolor',''),
('rpt_flash','stackvar','.hcvc',''),
('rpt_flash','template','filetype1.htmt',''),
('rpt_flash','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_flash','top','','number of lines to show'),
('rpt_fnf','enabled','y','y if this report is enabled'),
('rpt_fnf','hitcountvar','.hitcount',''),
('rpt_fnf','hittot','n404',''),
('rpt_fnf','pathvar','hits.path',''),
('rpt_fnf','template','filelist.htmt',''),
('rpt_graphics','bytetotalvar','.filebytes',''),
('rpt_graphics','bytevar','x.bytes',''),
('rpt_graphics','enabled','y','y if this report is enabled'),
('rpt_graphics','filetotalvar','.filecount',''),
('rpt_graphics','hitcountvar','x.hitcount',''),
('rpt_graphics','hittotalvar','.filehits',''),
('rpt_graphics','labelvar','hits.path',''),
('rpt_graphics','legendcolor','wtvsources.sourcecolor',''),
('rpt_graphics','legendname','wtvsources.sourceid',''),
('rpt_graphics','stackcolor','wtvsources.sourcecolor',''),
('rpt_graphics','stackvar','.hcvc',''),
('rpt_graphics','template','filetype1.htmt',''),
('rpt_graphics','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_graphics','top','10','number of entries to show'),
('rpt_heading','template','heading.htmt',''),
('rpt_html','bytetotalvar','htmlbytes',''), -- varname in filetype1.htmt and which gobal var it will access
('rpt_html','bytevar','x.bytes',''),
('rpt_html','colorclass','wtcolors.colorclass',''),
('rpt_html','enabled','y','y if this report is enabled'),
('rpt_html','filetotalvar','htmlfiles',''),
('rpt_html','hitcountvar','x.hitcount',''),
('rpt_html','hittotalvar','htmlhits',''),
('rpt_html','labelvar','hits.path',''),
('rpt_html','legendcolor','wtvsources.sourcecolor',''),
('rpt_html','legendname','wtvsources.sourceid',''),
('rpt_html','queryfiletype2','',''),
('rpt_html','queryfiletype3','',''),
('rpt_html','stackcolor','wtvsources.sourcecolor',''),
('rpt_html','stackvar','.hcvc',''),
('rpt_html','template','filetype1.htmt',''),
('rpt_html','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_html','top','30','number of entries to show'),
('rpt_illref','bytesvar','.bytes',''),
('rpt_illref','enabled','y','y if this report is enabled'),
('rpt_illref','pathvar','hits.path',''),
('rpt_illref','hitcountvar','.hitcount',''),
('rpt_illref','referrervar','hits.referrerurl',''),
('rpt_illref','template','illref.htmt',''),
('rpt_illref','top','','number of entries to show'),
('rpt_illref','totalbytesvar','.tbytes',''),
('rpt_illref','totaldomsvar','.ndom',''),
('rpt_illref','totalfilesvar','.nf',''),
('rpt_illref','totalhitcountvar','.thitcount',''),
('rpt_java','bytetotalvar','.filebytes',''),
('rpt_java','bytevar','x.bytes',''),
('rpt_java','enabled','y','y if this report is enabled'),
('rpt_java','filetotalvar','.filecount',''),
('rpt_java','hitcountvar','x.hitcount',''),
('rpt_java','hittotalvar','.filehits',''),
('rpt_java','labelvar','hits.path',''),
('rpt_java','legendcolor','wtvsources.sourcecolor',''),
('rpt_java','legendname','wtvsources.sourceid',''),
('rpt_java','stackcolor','wtvsources.sourcecolor',''),
('rpt_java','stackvar','.hcvc',''),
('rpt_java','template','filetype1.htmt',''),
('rpt_java','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_java','top','','number of lines to show'),
('rpt_localquery','a1head','Filename',''),
('rpt_localquery','a1var','hits.path',''),
('rpt_localquery','a2head','%[nlquery]% Queries',''),
('rpt_localquery','a2var','hits.myquery',''),
('rpt_localquery','col1t','hits',''),
('rpt_localquery','col1tv','.tqh',''),
('rpt_localquery','col1v','.qh',''),
('rpt_localquery','enabled','y','y if this report is enabled'),
('rpt_localquery','template','localquery.htmt',''),
('rpt_localquery','top','30','number of entries to show'),
('rpt_nhits','col1s','1',''),
('rpt_nhits','col1t','Hits',''),
('rpt_nhits','col1tv','totalhitsni',''),
('rpt_nhits','col1v','visits.ninvisit',''),
('rpt_nhits','col2s','1024',''),
('rpt_nhits','col2t','KB',''),
('rpt_nhits','col2tv','totalkbni',''),
('rpt_nhits','col2v','visits.bytesinvisit',''),
('rpt_nhits','col3maxv','.m',''),
('rpt_nhits','col3s','1',''),
('rpt_nhits','col3t','NI visits',''),
('rpt_nhits','col3tv','totalvisitsni',''),
('rpt_nhits','col3v','=1',''),
('rpt_nhits','coldom','visits.vdomain',''),
('rpt_nhits','enabled','y','y if this report is enabled'),
('rpt_nhits','legendcolor','wtvclasses.vbarcolor',''),
('rpt_nhits','legendname','wtvclasses.vclass',''),
('rpt_nhits','newdomain','wtdomhist.dhdom',''),
('rpt_nhits','stackcolor','wtvclasses.vbarcolor',''),
('rpt_nhits','stackvar','wtvclasses.vbarcolor',''),
('rpt_nhits','template','visitsbycount.htmt',''),
('rpt_nviews','col1s','1',''),
('rpt_nviews','col1t','Views',''),
('rpt_nviews','col1tv','htmlhitsni',''),
('rpt_nviews','col1v','visits.htmlinvisit',''),
('rpt_nviews','col2s','1024',''),
('rpt_nviews','col2t','KB',''),
('rpt_nviews','col2tv','htmlkbni',''),
('rpt_nviews','col2v','visits.bytesinvisit',''),
('rpt_nviews','col3maxv','.m',''),
('rpt_nviews','col3s','1',''),
('rpt_nviews','col3t','NI visits',''),
('rpt_nviews','col3tv','totalvisitsni',''),
('rpt_nviews','col3v','=1',''),
('rpt_nviews','coldom','visits.vdomain',''),
('rpt_nviews','enabled','y','y if this report is enabled'),
('rpt_nviews','legendcolor','wtvclasses.vbarcolor',''),
('rpt_nviews','legendname','wtvclasses.vclass',''),
('rpt_nviews','newdomain','wtdomhist.dhdom',''),
('rpt_nviews','stackcolor','wtvclasses.vbarcolor',''),
('rpt_nviews','stackvar','wtvclasses.vbarcolor',''),
('rpt_nviews','template','visitsbycount.htmt',''),
('rpt_other','bytetotalvar','.filebytes',''),
('rpt_other','bytevar','x.bytes',''),
('rpt_other','enabled','y','y if this report is enabled'),
('rpt_other','filetotalvar','.filecount',''),
('rpt_other','hitcountvar','x.hitcount',''),
('rpt_other','hittotalvar','.filehits',''),
('rpt_other','labelvar','hits.path',''),
('rpt_other','legendcolor','wtvsources.sourcecolor',''),
('rpt_other','legendname','wtvsources.sourceid',''),
('rpt_other','stackcolor','wtvsources.sourcecolor',''),
('rpt_other','stackvar','.hcvc',''),
('rpt_other','template','filetype1.htmt',''),
('rpt_other','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_other','top','','number of lines to show'),
('rpt_paths','bytesvar','hits.txsize',''),
('rpt_paths','countvar','wtcumpath.ccnt',''),
('rpt_paths','pathvar','hits.path',''),
('rpt_paths','enabled','y','y if this report is enabled'),
('rpt_paths','fromvar','wtcumpath.cfrom',''),
('rpt_paths','tablebytes','cbytes',''),
('rpt_paths','tablecnt','ccnt',''),
('rpt_paths','tablename','wtcumpath',''),
('rpt_paths','sqltemplate','pathsql.htmt',''),
('rpt_paths','template','paths1.htmt',''),
('rpt_paths','tovar','wtcumpath.cto',''),
('rpt_paths','trim','100','take only top N paths. Make less than 200 for speed and legibility.'),
('rpt_paths','dftfile','index.html','default filename if null or index.html'),
('rpt_paths','trimref','^http:\\/\\/www\\.example\\.org','trim this prefix off referrer, regexp, also used in query'),
('rpt_paths','urlvar','hits.referrerurl',''),
('rpt_pie2','enabled','y','y if the pie chart section is enabled'),
('rpt_pie2','longclass','longpie',''),
('rpt_pie2','shortclass','shortpie',''),
('rpt_pie2','stclass','subtitle',''),
('rpt_pie2','template','piecharts.htmt',''),
('rpt_query','col0head','%[nquery]% Queries',''),
('rpt_query','col0v','nquery',''),
('rpt_query','col0h','Queries',''),
('rpt_query','col1s','1024',''),
('rpt_query','col1t','KB',''),
('rpt_query','col1tv','.tqb',''),
('rpt_query','col1v','.bytes',''),
('rpt_query','col2s','1',''),
('rpt_query','col2t','hits',''),
('rpt_query','col2tv','.tqh',''),
('rpt_query','col2v','.hitcount',''),
('rpt_query','enabled','y','y if this report is enabled'),
('rpt_query','labelvar','hits.referrerquery',''),
('rpt_query','template','histo2n.htmt',''),
('rpt_query','top','30','number of entries to show'),
('rpt_referrer','col0head','%[nreferrer]% Referrers',''),
('rpt_referrer','col0v','nreferrer',''),
('rpt_referrer','col0h','Referrers',''),
('rpt_referrer','col1s','1024',''),
('rpt_referrer','col1t','KB',''),
('rpt_referrer','col1tv','.tqb',''),
('rpt_referrer','col1v','.bytes',''),
('rpt_referrer','col2s','1',''),
('rpt_referrer','col2t','hits',''),
('rpt_referrer','col2tv','.tqh',''),
('rpt_referrer','col2v','.hitcount',''),
('rpt_referrer','enabled','y','y if this report is enabled'),
('rpt_referrer','labelvar','hits.referrerurl',''),
('rpt_referrer','newrefvar','.rurl',''), -- 20180610
('rpt_referrer','template','referrer.htmt',''),
('rpt_referrer','top','30','number of entries to show'),
('rpt_referrer','watchvar','wtreferrercolor.rcclass',''),
('rpt_referrerdom','col0head','%[nreferrer]% Referrers',''), -- referring domain
('rpt_referrerdom','col0v','nreferrer',''),
('rpt_referrerdom','col0h','Referrers',''),
('rpt_referrerdom','col1s','1024',''),
('rpt_referrerdom','col1t','KB',''),
('rpt_referrerdom','col1tv','.tqb',''),
('rpt_referrerdom','col1v','.bytes',''),
('rpt_referrerdom','col2s','1',''),
('rpt_referrerdom','col2t','hits',''),
('rpt_referrerdom','col2tv','.tqh',''),
('rpt_referrerdom','col2v','.hitcount',''),
('rpt_referrerdom','enabled','y','y if this report is enabled'),
('rpt_referrerdom','labelvar','.refdom',''), -- computed in the query, domain name from referrer
('rpt_referrerdom','newrefvar','wtcumref.refurl',''),
('rpt_referrerdom','template','referrer.htmt',''),
('rpt_referrerdom','top','30','number of entries to show'),
('rpt_referrerdom','watchvar','wtreferrercolor.rcclass',''),
('rpt_retcode','bytesvar','.bytesize',''),
('rpt_retcode','enabled','y','y if this report is enabled'),
('rpt_retcode','hitcountvar','.hitcount',''),
('rpt_retcode','meaningvar','wtretcodes.meaning',''),
('rpt_retcode','retcodevar','hits.retcode',''),
('rpt_retcode','goodvar','wtretcodes.good',''),
('rpt_retcode','goodthresh','95','Show the good percentage in red if it below this value'),
('rpt_retcode','template','retcodetable.htmt',''),
('rpt_snd','bytetotalvar','.filebytes',''),
('rpt_snd','bytevar','x.bytes',''),
('rpt_snd','enabled','y','y if this report is enabled'),
('rpt_snd','filetotalvar','.filecount',''),
('rpt_snd','hitcountvar','x.hitcount',''),
('rpt_snd','hittotalvar','.filehits',''),
('rpt_snd','labelvar','hits.path',''),
('rpt_snd','legendcolor','wtvsources.sourcecolor',''),
('rpt_snd','legendname','wtvsources.sourceid',''),
('rpt_snd','stackcolor','wtvsources.sourcecolor',''),
('rpt_snd','stackvar','.hcvc',''),
('rpt_snd','template','filetype1.htmt',''),
('rpt_snd','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_snd','top','','number of lines to show'),
('rpt_src','bytetotalvar','.filebytes',''),
('rpt_src','bytevar','x.bytes',''),
('rpt_src','enabled','y','y if this report is enabled'),
('rpt_src','filetotalvar','.filecount',''),
('rpt_src','hitcountvar','x.hitcount',''),
('rpt_src','hittotalvar','.filehits',''),
('rpt_src','labelvar','hits.path',''),
('rpt_src','legendcolor','wtvsources.sourcecolor',''),
('rpt_src','legendname','wtvsources.sourceid',''),
('rpt_src','stackcolor','wtvsources.sourcecolor',''),
('rpt_src','stackvar','.hcvc',''),
('rpt_src','template','filetype1.htmt',''),
('rpt_src','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_src','top','','number of lines to show'),
('rpt_summary','enabled','y','y if this report is enabled'),
('rpt_summary','graphwidth','300','width of graph for this report'),
('rpt_summary','lines','31','number of days to summarize'),
('rpt_summary','threshlo','11','show in gray if percent diff less'),
('rpt_summary','threshhi','25','show in red/blue if percent diff greater'),
('rpt_summary','threshwk','50','increment thresh for weekend'),
('rpt_summary','template','monthsum.htmt',''),
('rpt_tld','col0head','%[ntld]% TLDs',''),
('rpt_tld','col0h','TLDs',''),
('rpt_tld','col0v','ntld',''),
('rpt_tld','col1s','1',''),
('rpt_tld','col1t','Visits',''),
('rpt_tld','col1tv','totalvisits',''),
('rpt_tld','col1v','x.vno',''),
('rpt_tld','col2s','1024',''),
('rpt_tld','col2t','KB',''),
('rpt_tld','col2tv','totalkb',''),
('rpt_tld','col2v','x.bytes',''),
('rpt_tld','col3maxv','.m',''),
('rpt_tld','col3s','1',''),
('rpt_tld','col3t','hits',''),
('rpt_tld','col3tv','totalhits',''),
('rpt_tld','col3v','x.hitcount',''),
('rpt_tld','enabled','y','y if this report is enabled'),
('rpt_tld','expvar','countrynames.cnname',''),
('rpt_tld','labelvar','visits.tld',''),
('rpt_tld','labelvar2','',''),
('rpt_tld','legendcolor','wtvclasses.vbarcolor',''),
('rpt_tld','legendname','wtvclasses.vclass',''),
('rpt_tld','stripecolor','wtvclasses.vbarcolor',''),
('rpt_tld','stripecount','.hcvc',''),
('rpt_tld','template','histo3nn1.htmt',''),
('rpt_tld','top','','number of entries to show'),
('rpt_verb','bytesvar','.bytesize',''),
('rpt_verb','enabled','y','y if this report is enabled'),
('rpt_verb','hitcountvar','.hitcount',''),
('rpt_verb','template','verbtable.htmt',''),
('rpt_verb','verbvar','hits.verb',''),
('rpt_xml','bytetotalvar','.filebytes',''),
('rpt_xml','bytevar','x.bytes',''),
('rpt_xml','enabled','y','y if this report is enabled'),
('rpt_xml','filetotalvar','.filecount',''),
('rpt_xml','hitcountvar','x.hitcount',''),
('rpt_xml','hittotalvar','.filehits',''),
('rpt_xml','labelvar','hits.path',''),
('rpt_xml','legendcolor','wtvsources.sourcecolor',''),
('rpt_xml','legendname','wtvsources.sourceid',''),
('rpt_xml','stackcolor','wtvsources.sourcecolor',''),
('rpt_xml','stackvar','.hcvc',''),
('rpt_xml','template','filetype1.htmt',''),
('rpt_xml','deltaredthresh','20','show percent changes greater than this in red in short report'),
('rpt_xml','top','','number of lines to show'),
('rpt_year_domain','col0head','%[ydomain]% Visitors',''),
('rpt_year_domain','col0v','ydomain',''),
('rpt_year_domain','col0h','Visitors',''),
('rpt_year_domain','col1s','1048576',''),
('rpt_year_domain','col1t','MB',''),
('rpt_year_domain','col1tv','ytotalkb',''),
('rpt_year_domain','col1v','wtdomhist.dhbytes',''),
('rpt_year_domain','col2s','1',''),
('rpt_year_domain','col2t','Hits',''),
('rpt_year_domain','col2tv','ytotalhits',''),
('rpt_year_domain','col2v','wtdomhist.dhhits',''),
('rpt_year_domain','col2vg','wtdomhist.dhhtm',''),
('rpt_year_domain','col2vh','wtdomhist.dhgrf',''),
('rpt_year_domain','col3s','1',''),
('rpt_year_domain','col3t','Visits',''),
('rpt_year_domain','col3tv','ytotalvisits',''),
('rpt_year_domain','col3v','wtdomhist.dhvisits',''),
('rpt_year_domain','col4s','1',''),
('rpt_year_domain','col4t','DSLV',''),
('rpt_year_domain','col4tv','',''),
('rpt_year_domain','col4v','.dslv',''),
('rpt_year_domain','enabled','y','y if this report is enabled'),
('rpt_year_domain','labelvar','wtdomhist.dhdom',''),
('rpt_year_domain','template','cumdom.htmt',''),
('rpt_year_domain','top','20','number of entries to show'),
('rpt_year_referrer','col0head','%[yreferrer]% Referrers',''),
('rpt_year','col0h','Referrers',''), -- spurious
('rpt_year','col0v','yreferrer',''), -- spurious
('rpt_year_referrer','col1s','1048576',''),
('rpt_year_referrer','col1t','MB',''),
('rpt_year_referrer','col1tv','.tqb',''),
('rpt_year_referrer','col1v','.bytes',''),
('rpt_year_referrer','col2s','1',''),
('rpt_year_referrer','col2t','hits',''),
('rpt_year_referrer','col2tv','.tqh',''),
('rpt_year_referrer','col2v','.hits',''),
('rpt_year_referrer','enabled','y','y if this report is enabled'),
('rpt_year_referrer','labelvar','.refdom',''),
('rpt_year_referrer','template','yreferrer.htmt',''),
('rpt_year_referrer','top','20','number of entries to show'),
('rpt_year_query','col0tv','.tq',''),
('rpt_year_query','col0head','Queries',''),
('rpt_year_query','col1s','1048576',''),
('rpt_year_query','col1t','MB',''),
('rpt_year_query','col1tv','.tqb',''),
('rpt_year_query','col1v','.bytes',''),
('rpt_year_query','col2s','1',''),
('rpt_year_query','col2t','hits',''),
('rpt_year_query','col2tv','.tqh',''),
('rpt_year_query','col2v','.cnt',''),
('rpt_year_query','enabled','y','y if this report is enabled'),
('rpt_year_query','labelvar','wtcumquery.query',''),
('rpt_year_query','template','yquery.htmt',''),
('rpt_year_query','top','20','number of entries to show'),
('rpt_year_words','col0tv','.tw',''),
('rpt_year_words','col0head','Words',''),
('rpt_year_words','col1s','1',''),
('rpt_year_words','col1t','uses',''),
('rpt_year_words','col1tv','.twc',''),
('rpt_year_words','col1v','wtyquerywords.wcount',''),
('rpt_year_words','enabled','y','y if this report is enabled'),
('rpt_year_words','labelvar','wtyquerywords.word',''),
('rpt_year_words','template','ywords.htmt',''),
('rpt_year_words','top','20','number of entries to show'),
('rpt_day_words','col0tv','.tw',''),
('rpt_day_words','col0head','Words',''),
('rpt_day_words','col1s','1',''),
('rpt_day_words','col1t','uses',''),
('rpt_day_words','col1tv','.twc',''),
('rpt_day_words','col1v','wtdquerywords.wcount',''),
('rpt_day_words','enabled','y','y if this report is enabled'),
('rpt_day_words','labelvar','wtdquerywords.word',''),
('rpt_day_words','template','ywords.htmt',''),
('rpt_day_words','top','20','number of entries to show'),
('rpt_geoloc','a1head','CC',''),
('rpt_geoloc','a1var','.cc',''),
('rpt_geoloc','a2head','Continent',''),
('rpt_geoloc','a2var','.xcncontinent',''),
('rpt_geoloc','a3head','Country',''),
('rpt_geoloc','a3var','.xcnname',''),
('rpt_geoloc','a4head','City',''),
('rpt_geoloc','a4var','.city',''),
('rpt_geoloc','col1t','visits',''),
('rpt_geoloc','col1tv','qtvni',''), -- non indexer
('rpt_geoloc','col1v','.nv',''), -- total visits for this city
('rpt_geoloc','stripecolor','wtvclasses.vbarcolor',''),
('rpt_geoloc','stripecount','.hcvc',''), -- visits for this city+visitclass
('rpt_geoloc','legendcolor','wtvclasses.vbarcolor',''),
('rpt_geoloc','legendname','wtvclasses.vclass',''),
('rpt_geoloc','enabled','y','y if this report is enabled'),
('rpt_geoloc','template','geoloc.htmt',''),
('rpt_geoloc','top','30','number of entries to show'),
('rpt_repeat','a1head','Pathname',''),
('rpt_repeat','a1var','.hp',''),
('rpt_repeat','a2head','Domain',''),
('rpt_repeat','a2var','hits.domain',''),
('rpt_repeat','a3head','Browser',''),
('rpt_repeat','a3var','.bn',''),
('rpt_repeat','col1t','hits',''),
('rpt_repeat','col1tv','totalhits',''),
('rpt_repeat','col1v','.nhits',''),
('rpt_repeat','cutoff','5','show only file/domain pairs with at least this many hits'),
('rpt_repeat','skip','','filenames to ignore'),
('rpt_repeat','skipvar','hits.filename',''),
('rpt_repeat','enabled','y','y if this report is enabled'),
('rpt_repeat','top','100','max number of entries to show'),
('rpt_repeat','template','repeat.htmt','');

-- queries
DROP TABLE IF EXISTS wtqueries;
CREATE TABLE wtqueries(
 qrpt varchar(32), -- report name, fkey on wtreports
 qname VARCHAR(32), -- query name
 qvalue TEXT, -- query
 PRIMARY KEY(qrpt, qname)
);
INSERT INTO wtqueries (qrpt, qname, qvalue) VALUES
-- query run after hit loading to eliminate referrer spam identified by browser
('clean_hits','q','UPDATE hits SET referrerurl = \'\' WHERE browser LIKE \'%pycurl%\' and verb = \'GET\''),
-- query run after hit loading to delete internal Apache hits
('clean_hits','q2','DELETE FROM hits WHERE verb = \'OPTIONS\' OR verb = \'CONNECT\''),
-- visitdata query, will be expanded to handle hit slices
('visitdata','vq','SELECT $star FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE vn >= %[sllo]% AND vn <= %[slhi]% AND wtretcodes.good != 0 ORDER BY hits.vn, hits.sn'),
-- Insert a row into the daily history table
('update_wtdayhist','q',''),
-- heading queries, should be referenced in wtglobvar table below
('rpt_heading','qtrec','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits'),
('rpt_heading','qtb','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good = 1'),
('rpt_heading','qmintb','SELECT MIN(systime) AS first FROM hits'),
('rpt_heading','qminta','SELECT SUBSTR(FROM_UNIXTIME(MIN(systime)), 1, 16) AS first FROM hits'),
('rpt_heading','qmaxtb','SELECT MAX(systime) AS last FROM hits'),
('rpt_heading','qmaxta','SELECT SUBSTR(FROM_UNIXTIME(MAX(systime)), 1, 16) AS last FROM hits'),
('rpt_heading','qtv','SELECT COUNT(visitno) AS total FROM visits'),
('rpt_heading','qauthsess','SELECT COUNT(visitno) AS total FROM visits WHERE authid != \'\''),
('rpt_heading','qauthkb','SELECT SUM(bytesinvisit) AS total FROM visits WHERE authid != \'\''),
('rpt_heading','qauthhits','SELECT SUM(ninvisit) AS total FROM visits WHERE authid != \'\''),
('rpt_heading','qauthids','SELECT COUNT(*) AS total FROM (SELECT DISTINCT authid FROM visits WHERE authid != \'\') AS x'),
('rpt_heading','qtvni','SELECT COUNT(visitno) AS total FROM visits WHERE visits.source != \'indexer\''),
('rpt_heading','qtbni','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good = 1 AND visits.source != \'indexer\''),
('rpt_heading','qhtml','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\''),
('rpt_heading','qhtmlni','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\''),
('rpt_heading','qgraphic','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'graphic\''),
('rpt_heading','qgraphicni','SELECT COUNT(hits.domain) AS total, SUM(hits.txsize) AS bytes FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'graphic\' AND visits.source != \'indexer\''),
('rpt_heading','qhtmlfiles','SELECT COUNT(a.path) AS n FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\' GROUP BY hits.path) AS a'),
('rpt_heading','qhtmlfilesni','SELECT COUNT(a.path) AS n FROM (SELECT hits.path FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY hits.path) AS a'),
('rpt_heading','qytothits','SELECT SUM(ffilecnt) AS ytothits, SUM(ffilebytes) AS ytotbytes FROM wtcumfile'),
('rpt_heading','qyhtothits','SELECT SUM(ffilecnt) AS ytothits, SUM(ffilebytes) AS ytotbytes FROM wtcumfile INNER JOIN wtsuffixclass ON ffilename REGEXP CONCAT(suf, \'$\') WHERE wtsuffixclass.sufclass = \'html\''),
('rpt_heading','qindex','SELECT COUNT(visitno) AS nindexvisits, SUM(visits.ninvisit) AS indexhits, SUM(bytesinvisit) AS indexbytes FROM visits WHERE visits.source = \'indexer\''),
('rpt_heading','qlink','SELECT COUNT(visitno) AS nlinkvisits, SUM(visits.ninvisit) AS linkhits, SUM(bytesinvisit) AS linkbytes FROM visits WHERE visits.source LIKE \'link%\''),
('rpt_heading','qsearch','SELECT COUNT(hits.path) AS nsearches FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good = 1 AND hits.referrerquery != \'\''),
('rpt_heading','qsearch2','SELECT COUNT(visitno) AS nsearchvisits, SUM(bytesinvisit) AS searchbytes FROM visits WHERE visits.source LIKE \'search%\''),
('rpt_heading','qnhp','SELECT COUNT(a.path) AS nheadp FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtheadpages ON wtheadpages.headpage = hits.filename WHERE wtretcodes.good = 1 AND wtheadpages.headpage IS NOT NULL GROUP BY hits.path) AS a'),
('rpt_heading','qhp','SELECT COUNT(hits.path) AS hphits, SUM(hits.txsize) AS hpbytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtheadpages ON wtheadpages.headpage = hits.filename WHERE wtretcodes.good = 1 AND wtheadpages.headpage IS NOT NULL'),
('rpt_heading','qzhtml','SELECT COUNT(visitno) AS x, SUM(visits.ninvisit) AS y, SUM(bytesinvisit) AS z FROM visits WHERE htmlinvisit = 0'),
('rpt_heading','qnzhtml','SELECT COUNT(visitno) AS x FROM visits WHERE htmlinvisit != 0'),
('rpt_heading','qnzhtmlni','SELECT COUNT(visitno) AS x FROM visits WHERE htmlinvisit != 0 AND visits.source != \'indexer\''),
('rpt_heading','qndomains','SELECT COUNT(*) AS n FROM (SELECT DISTINCT domain FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0) AS a'),
('rpt_heading','qnewdomains','SELECT COUNT(*) AS n FROM (SELECT DISTINCT domain FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtdomhist ON hits.domain = wtdomhist.dhdom WHERE wtretcodes.good != 0 AND wtdomhist.dhdom IS NULL) AS a'),
('rpt_heading','qntld','SELECT COUNT(*) AS n FROM (SELECT DISTINCT tld FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0) AS a'),
('rpt_heading','qnbrow','SELECT COUNT(*) AS n FROM (SELECT browsername, platformtype FROM visits GROUP BY browsername, platformtype) AS a'), -- 2009-03-27
('rpt_heading','qnrefer','SELECT COUNT(*) AS n FROM (SELECT DISTINCT referrerurl FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND referrerquery = \'\') AS a'),
('rpt_heading','qnquery','SELECT COUNT(*) AS n FROM (SELECT DISTINCT referrerquery FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0  AND referrerquery != \'\') AS a'),
('rpt_heading','qnengine','SELECT COUNT(*) AS n FROM (SELECT DISTINCT referrerurl FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerquery != \'\') AS a'),
('rpt_heading','qnclasses','SELECT COUNT(*) AS n FROM (SELECT DISTINCT visitclass FROM visits) AS a'),
('rpt_heading','qydomain','SELECT COUNT(dhdom) AS n FROM wtdomhist'),
('rpt_heading','qyfile','SELECT COUNT(ffilename) AS n FROM wtcumfile'),
('rpt_heading','qyhfile','SELECT COUNT(ffilename) AS n FROM wtcumfile INNER JOIN wtsuffixclass ON ffilename REGEXP CONCAT(suf, \'$\') WHERE wtsuffixclass.sufclass = \'html\''),
('rpt_heading','qyreferrer','SELECT COUNT(refurl) AS n FROM wtcumref WHERE refwithquery = 0'),
('rpt_heading','qhitsnovisit','SELECT COUNT(hits.domain) AS n FROM hits LEFT OUTER JOIN visits ON vn = visitno WHERE visitno IS NULL'),
('rpt_heading','qdomsnovisit','SELECT COUNT(*) AS n FROM (SELECT DISTINCT domain FROM hits LEFT OUTER JOIN visits ON vn = visitno WHERE visitno IS NULL) AS a'),
('rpt_heading','q404','SELECT COUNT(hits.domain) AS n FROM hits INNER JOIN visits ON vn = visitno LEFT OUTER JOIN wtexpected404 ON hits.path REGEXP wtexpected404.f404 LEFT OUTER JOIN wthackfilenames ON hits.path REGEXP wthackfilenames.hackfileregex LEFT OUTER JOIN wthackfiletypes ON hits.filetype = wthackfiletypes.hackfiletype WHERE hits.retcode = \'404\' AND wtexpected404.f404 IS NULL AND wthackfilenames.hackfileregex IS NULL AND wthackfiletypes.hackfiletype IS NULL AND visitclass != \'indexer\''),
('rpt_heading','qdayhistfirst','SELECT FROM_UNIXTIME(MIN(dbegtimebin)) AS x FROM wtdayhist'),
('rpt_heading','qdomhistfirst','SELECT MIN(dhfirst) AS x FROM wtdomhist'),
('rpt_heading','qgooglecrawldate','SELECT FROM_UNIXTIME(MAX(lglast)) AS x FROM wtcumgoog'),
('rpt_heading','qngoogletoday','SELECT COUNT(path) AS totgoo FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0 AND (hits.domain LIKE \'%googlebot.com\' OR hits.domain LIKE \'%googlebot.com[us%\')'),
('rpt_heading','qnnevergooglehtml','SELECT COUNT(cfilename) AS x FROM wtpclasses LEFT OUTER JOIN wtcumgoog ON lgpath REGEXP cfilename WHERE lgpath IS NULL AND cfilename LIKE \'%.html\''),
-- nav bar
('rpt_heading','qnavbar','SELECT * FROM wtreports INNER JOIN wtreportoptions ON reportid = optid WHERE optname = \'enabled\' AND optvalue = \'y\' AND repord != 0 ORDER BY repord'),
-- summary
('rpt_summary','qmonthsum','SELECT *, dayofweek(from_unixtime(dbegtimebin)) as dow, SUBSTR(FROM_UNIXTIME(dbegtimebin), 1, 16) AS xbeg, SUBSTR(FROM_UNIXTIME(dendtimebin), 1, 16) AS xend FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%'),
('rpt_summary','qmonthsumminhits','SELECT MIN(x.y) AS mindhits FROM (SELECT dhits AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxhits','SELECT MAX(x.y) AS maxdhits FROM (SELECT dhits AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumminb','SELECT MIN(x.y) AS mindbytes FROM (SELECT dbytes AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxb','SELECT MAX(x.y) AS maxdbytes FROM (SELECT dbytes AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumtotb','SELECT SUM(x.y) AS totdbytes FROM (SELECT dbytes AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumminv','SELECT MIN(x.y) AS mindvisits FROM (SELECT dvisits AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxv','SELECT MAX(x.y) AS maxdvisits FROM (SELECT dvisits AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumminh','SELECT MIN(x.y) AS mindhtmlpages FROM (SELECT dhtmlpages AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxh','SELECT MAX(x.y) AS maxdhtmlpages FROM (SELECT dhtmlpages AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumming','SELECT MIN(x.y) AS mindgraphicpages FROM (SELECT dgraphicpages AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxg','SELECT MAX(x.y) AS maxdgraphicpages FROM (SELECT dgraphicpages AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumminud','SELECT MIN(x.y) AS mindudom FROM (SELECT dndomainstoday AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxud','SELECT MAX(x.y) AS maxdudom FROM (SELECT dndomainstoday AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumminnd','SELECT MIN(x.y) AS mindndom FROM (SELECT dnewdomainstoday AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxnd','SELECT MAX(x.y) AS maxdndom FROM (SELECT dnewdomainstoday AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsumminnixv','SELECT MIN(x.y) AS minnixv FROM (SELECT dvisits-dnindexvisits AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
('rpt_summary','qmonthsummaxnixv','SELECT MAX(x.y) AS maxnixv FROM (SELECT dvisits-dnindexvisits AS y FROM wtdayhist ORDER BY dbegtimebin DESC LIMIT %[rpt_summary_lines]%) AS x'),
--
('rpt_pie2','queryshort','SELECT * FROM wtpiequeries WHERE shortweight != 000 ORDER BY shortweight DESC'),
('rpt_pie2','querylong','SELECT * FROM wtpiequeries WHERE longweight != 000 ORDER BY longweight DESC'),
--
('rpt_html','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_html','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\''),
('rpt_html','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'html\' GROUP BY hits.path) AS a'),
('rpt_html','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_graphics','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'graphic\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'graphic\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_graphics','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'graphic\''),
('rpt_graphics','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'graphic\' GROUP BY hits.path) AS a'),
('rpt_graphics','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_css','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'css\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'css\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_css','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'css\''),
('rpt_css','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'css\' GROUP BY hits.path) AS a'),
('rpt_css','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_flash','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'swf\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'swf\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_flash','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'swf\''),
('rpt_flash','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'swf\' GROUP BY hits.path) AS a'),
('rpt_flash','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_dl','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'dl\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'dl\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_dl','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'dl\''),
('rpt_dl','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'dl\' GROUP BY hits.path) AS a'),
('rpt_dl','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_snd','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'snd\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'snd\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_snd','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'snd\''),
('rpt_snd','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'snd\' GROUP BY hits.path) AS a'),
('rpt_snd','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_xml','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'xml\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'xml\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_xml','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'xml\''),
('rpt_xml','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'xml\' GROUP BY hits.path) AS a'),
('rpt_xml','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_java','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'Java\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'Java\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_java','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'Java\''),
('rpt_java','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'Java\' GROUP BY hits.path) AS a'),
('rpt_java','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_src','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'src\' GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'src\' GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_src','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'src\''),
('rpt_src','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code INNER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass = \'src\' GROUP BY hits.path) AS a'),
('rpt_src','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_other','queryfiletype','SELECT hits.path, x.hitcount, x.bytes, COUNT(hits.path) AS hcvc, SUM(hits.txsize) AS bf, MAX(wtcolors.colorclass), visits.source, wtvsources.sourcecolor FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN (SELECT hits.path AS f, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass IS NULL GROUP BY hits.path ORDER BY hitcount DESC %[limitn]%) AS x ON f = hits.path LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename INNER JOIN wtvsources ON visits.source = sourceid INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.sufclass IS NULL GROUP BY hits.path, visits.source ORDER BY hitcount DESC, hits.path, visits.source'),
('rpt_other','queryfiletype2','SELECT COUNT(hits.domain) AS filehits, SUM(hits.txsize) AS filebytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.suf IS NULL'),
('rpt_other','queryfiletype3','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf WHERE wtretcodes.good = 1 AND wtsuffixclass.suf IS NULL GROUP BY hits.path) AS a'),
('rpt_other','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_fnf','queryfilelist','SELECT hits.path, COUNT(hits.path) AS hitcount FROM hits LEFT OUTER JOIN wtexpected404 ON hits.path REGEXP wtexpected404.f404 LEFT OUTER JOIN wthackfilenames ON hits.path REGEXP wthackfilenames.hackfileregex LEFT OUTER JOIN wthackfiletypes ON hits.filetype = wthackfiletypes.hackfiletype INNER JOIN visits ON vn = visitno WHERE visitclass != \'indexer\' AND hits.retcode = \'404\' AND wtexpected404.f404 IS NULL AND wthackfilenames.hackfileregex IS NULL AND wthackfiletypes.hackfiletype IS NULL GROUP BY hits.path ORDER BY hitcount DESC'),
('rpt_403','query403','SELECT hits.path, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes, hits.referrerurl FROM hits WHERE retcode = \'403\' GROUP BY hits.path, hits.referrerurl ORDER BY hitcount DESC %[limitn]%'),
('rpt_403','query4032','SELECT COUNT(hits.path) AS filehits, SUM(hits.txsize) AS filebytes FROM hits WHERE hits.retcode = \'403\''),
('rpt_403','query4033','SELECT COUNT(a.path) AS filecount FROM (SELECT hits.path FROM hits WHERE hits.retcode = \'403\' GROUP BY hits.path) AS a'),
('rpt_illref','queryillref','SELECT  hits.path, referrerurl, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtlocalreferrerregexp.regex IS NULL AND wtretcodes.good = 1 AND hits.referrerurl != \'\' AND wtsuffixclass.sufclass != \'html\' AND hits.referrerurl NOT LIKE \'%images%\' AND hits.referrerurl NOT LIKE \'%.google.%\' AND hits.domain NOT LIKE \'%.googleusercontent.%\' AND hits.filename != \'favicon.ico\' AND hits.filename != \'robots.txt\' AND hits.filename NOT LIKE \'%.css\' GROUP BY hits.path, referrerurl ORDER BY hitcount DESC %[limitn]%'),
('rpt_illref','queryillref2','SELECT COUNT(a.referrerurl) AS ndom FROM (SELECT referrerurl FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtlocalreferrerregexp.regex IS NULL AND wtretcodes.good = 1 AND hits.referrerurl != \'\' AND wtsuffixclass.sufclass != \'html\' AND hits.referrerurl NOT LIKE \'%images%\' AND hits.referrerurl NOT LIKE \'%.google.%\' AND hits.domain NOT LIKE \'%.googleusercontent.%\' AND hits.filename != \'favicon.ico\' AND hits.filename != \'robots.txt\' AND hits.filename NOT LIKE \'%.css\' GROUP BY referrerurl) AS a'),
('rpt_illref','queryillref3','SELECT COUNT(hits.domain) AS thitcount, SUM(hits.txsize) AS tbytes FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtlocalreferrerregexp.regex IS NULL AND wtretcodes.good = 1 AND hits.referrerurl != \'\' AND wtsuffixclass.sufclass != \'html\' AND hits.referrerurl NOT LIKE \'%images%\' AND hits.referrerurl NOT LIKE \'%.google.%\' AND hits.domain NOT LIKE \'%.googleusercontent.%\' AND hits.filename != \'favicon.ico\' AND hits.filename != \'robots.txt\' AND hits.filename NOT LIKE \'%.css\''),
('rpt_illref','queryillref4','SELECT COUNT(a.path) AS nf FROM (SELECT hits.path FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtlocalreferrerregexp.regex IS NULL AND wtretcodes.good = 1 AND hits.referrerurl != \'\' AND wtsuffixclass.sufclass != \'html\' AND hits.referrerurl NOT LIKE \'%images%\' AND hits.referrerurl NOT LIKE \'%.google.%\' AND hits.domain NOT LIKE \'%.googleusercontent.%\' AND hits.filename != \'favicon.ico\' AND hits.filename != \'robots.txt\' AND hits.filename NOT LIKE \'%.css\' GROUP BY hits.path) AS a'),
('rpt_accesstime','queryaccesstime','SELECT HOUR(FROM_UNIXTIME(hits.systime)) AS hh, COUNT(hits.path) AS hitcount, SUM(hits.txsize) AS bytes, SUM(sufclass = \'html\') AS xx, SUM(sufclass = \'graphic\') AS xg FROM hits LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good = 1 GROUP BY hh ORDER BY hh'),
('rpt_accesstime','queryaccesstime2','SELECT MAX(a.hitcount) AS busy FROM (SELECT HOUR(FROM_UNIXTIME(hits.systime)) AS hh, COUNT(hits.path) AS hitcount FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good = 1 GROUP BY hh) AS a'),
('rpt_duration','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
('rpt_duration','queryduration','SELECT visits.vdomain, visits.visitclass, visits.bytesinvisit, visits.ninvisit, visits.htmlinvisit, visits.duration, wtvclasses.vbarcolor FROM visits INNER JOIN wtvclasses ON visits.visitclass = vclass WHERE visits.visitclass != \'indexer\' AND visits.visitclass != \'rss\' AND visits.htmlinvisit > 0 ORDER BY visits.duration DESC %[limitn]%'),
('rpt_nhits','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
('rpt_nhits','query1','SELECT visits.ninvisit, visits.visitclass, visits.bytesinvisit, visits.vdomain, wtvclasses.vbarcolor, wtdomhist.dhdom FROM visits INNER JOIN wtvclasses ON visits.visitclass = vclass LEFT OUTER JOIN wtdomhist ON visits.vdomain = wtdomhist.dhdom WHERE visits.visitclass != \'indexer\' AND visits.visitclass != \'rss\' ORDER BY ninvisit, visitclass'),
('rpt_nhits','query2','SELECT MAX(a.x) AS m FROM (SELECT COUNT(visitno) AS x FROM visits WHERE visits.visitclass != \'indexer\' AND visits.visitclass != \'rss\' GROUP BY visits.ninvisit) AS a'),
('rpt_nviews','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
('rpt_nviews','query1','SELECT visits.htmlinvisit, visits.visitclass, visits.bytesinvisit, visits.vdomain, wtvclasses.vbarcolor, wtdomhist.dhdom FROM visits INNER JOIN wtvclasses ON visits.visitclass = vclass LEFT OUTER JOIN wtdomhist ON visits.vdomain = wtdomhist.dhdom WHERE visits.visitclass != \'indexer\' AND visits.visitclass != \'rss\' ORDER BY htmlinvisit, visitclass'),
('rpt_nviews','query2','SELECT MAX(a.x) AS m FROM (SELECT COUNT(visits.visitno) AS x FROM visits WHERE visits.visitclass != \'indexer\' AND visits.visitclass != \'rss\' GROUP BY visits.htmlinvisit) AS a'),
('rpt_tld','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
('rpt_tld','query1','SELECT visits.tld, x.hitcount, x.bytes, x.vno, SUM(visits.ninvisit) AS hcvc, visits.visitclass, countrynames.cnname, wtvclasses.vbarcolor FROM visits INNER JOIN (SELECT tld AS z, COUNT(visitno) AS vno, SUM(visits.ninvisit) AS hitcount, SUM(bytesinvisit) AS bytes FROM visits GROUP BY z ORDER BY z) AS x ON z = tld LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode INNER JOIN wtvclasses ON visitclass = vclass GROUP BY tld, visitclass ORDER BY hitcount DESC, tld, visitclass %[limitn]%'),
('rpt_tld','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits GROUP BY tld) AS a'),
('rpt_domain','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
('rpt_domain','query1','SELECT visits.vdomain, x.hitcount, x.bytes, x.vno, SUM(visits.ninvisit) AS hcvc, wtvclasses.vbarcolor, MAX(wtdomhist.dhdom) AS dhd, DATEDIFF(\'%[lastdate]%\', MAX(wtdomhist.dhlast)) AS dspv FROM visits INNER JOIN (SELECT vdomain AS z, COUNT(visitno) AS vno, SUM(visits.ninvisit) AS hitcount, SUM(bytesinvisit) AS bytes FROM visits GROUP BY z ORDER BY hitcount DESC %[limitn]%) AS x ON z = vdomain INNER JOIN wtvclasses ON visitclass = vclass LEFT OUTER JOIN wtdomhist ON visits.vdomain = wtdomhist.dhdom GROUP BY vdomain, visitclass ORDER BY hitcount DESC, vdomain, visitclass'), -- 20180610
('rpt_domain','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits GROUP BY vdomain) AS a'),
('rpt_domain2','query1','SELECT visits.ttld, COUNT(visits.ttld) AS nv, SUM(visits.bytesinvisit) AS bytes, SUM(visits.ninvisit) AS hits, SUM(visits.htmlinvisit) AS h, SUM(visits.graphicsinvisit) AS g FROM visits GROUP BY visits.ttld ORDER BY hits DESC %[limitn]%;'),
('rpt_domain2','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits GROUP BY ttld) AS a'),
('rpt_domain3','query1','SELECT visits.tttld, COUNT(visits.tttld) AS nv, SUM(visits.bytesinvisit) AS bytes, SUM(visits.ninvisit) AS hits, SUM(visits.htmlinvisit) AS h, SUM(visits.graphicsinvisit) AS g FROM visits GROUP BY visits.tttld ORDER BY hits DESC %[limitn]%;'),
('rpt_domain3','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits GROUP BY tttld) AS a'),
('rpt_authid','query1','SELECT visits.authid, COUNT(visits.authid) AS nv, SUM(visits.bytesinvisit) AS bytes, SUM(visits.ninvisit) AS hits, SUM(visits.htmlinvisit) AS h, SUM(visits.graphicsinvisit) AS g FROM visits%[rpt_authid_restrict]% GROUP BY visits.authid ORDER BY hits DESC %[limitn]%;'),
('rpt_authid','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits%[rpt_authid_restrict]% GROUP BY authid) AS a'),
('rpt_class','legendquery','SELECT * FROM  wtvsources ORDER BY sourceid'),
('rpt_class','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits GROUP BY visits.visitclass) AS a'),
('rpt_class','query1','SELECT visits.visitclass, x.hitcount, x.bytes, x.vno, SUM(visits.ninvisit) AS hcvc, wtvsources.sourcecolor FROM visits INNER JOIN (SELECT visitclass AS z, COUNT(visitno) AS vno, SUM(visits.ninvisit) AS hitcount, SUM(bytesinvisit) AS bytes FROM visits GROUP BY z ORDER BY z) AS x ON z = visitclass INNER JOIN wtvsources ON visits.source = sourceid GROUP BY visits.visitclass, visits.source ORDER BY hitcount DESC, visits.visitclass, visits.source'),
('rpt_browser','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
('rpt_browser','query1','SELECT visits.browsername, visits.platformtype, CONCAT(MAX(visits.browsertype),\'/\',visits.platformtype) AS xid, x.hitcount, x.bytes, x.vno, SUM(visits.ninvisit) AS hcvc, visits.visitclass, wtvclasses.vbarcolor FROM visits INNER JOIN (SELECT visits.browsername AS z, visits.platformtype AS zz, COUNT(visits.visitno) AS vno, SUM(visits.ninvisit) AS hitcount, SUM(visits.bytesinvisit) AS bytes FROM visits GROUP BY z, zz ORDER BY z, zz %[limitn]%) AS x ON z = visits.browsername AND zz = visits.platformtype INNER JOIN wtvclasses ON visits.visitclass = vclass GROUP BY visits.browsername, visits.platformtype, visits.visitclass ORDER BY hitcount DESC, visits.browsername, visits.platformtype, visits.visitclass'),
('rpt_browser','query2','SELECT MAX(a.x) AS m FROM (SELECT SUM(visits.ninvisit) AS x FROM visits GROUP BY visits.browsername, visits.platformtype) AS a'),
('rpt_query','query1','SELECT MAX(hits.referrerurl), hits.referrerquery, SUM(hits.txsize) AS bytes, COUNT(hits.referrerquery) AS hitcount FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND hits.referrerquery != \'\' GROUP BY referrerquery ORDER BY hitcount DESC %[limitn]%'),
('rpt_query','query2','SELECT COUNT(hits.referrerquery) AS tqh, SUM(hits.txsize) AS tqb FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND hits.referrerquery != \'\''),
('rpt_engine','query1','SELECT hits.referrerurl, SUM(hits.txsize) AS bytes, COUNT(hits.referrerurl) AS hitcount, referrerurl REGEXP \'image\' AS imageflag FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND referrerquery != \'\' GROUP BY referrerurl ORDER BY hitcount DESC %[limitn]%'),
('rpt_engine','query2','SELECT SUM(hits.txsize) AS tqb, COUNT(hits.referrerurl) AS tqh FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND referrerquery != \'\''),
('rpt_google','query1','SELECT hits.path, hits.txsize, FROM_UNIXTIME(hits.systime) AS lgdate FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0 AND (hits.domain LIKE \'%googlebot.com\' OR hits.domain LIKE \'%googlebot.com[us%\') ORDER BY systime DESC %[limitn]%'),
('rpt_filesize','query1','SELECT COUNT(*) AS a, POWER(10, TRUNCATE(LOG10(txsize), 0)+1) AS b, SUM(txsize) AS c FROM hits GROUP BY b ORDER BY b'),
('rpt_filesize','query2','SELECT MAX(x.a) AS f FROM (SELECT COUNT(*) AS a, POWER(10, TRUNCATE(LOG10(txsize), 0)+1) AS b FROM hits GROUP BY b) AS x'),
('rpt_referrer','query1','SELECT hits.referrerurl, SUM(hits.txsize) AS bytes, COUNT(hits.referrerurl) AS hitcount, MAX(wtcumref.refurl) AS rurl, MAX(wtreferrercolor.rcclass) FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex LEFT OUTER JOIN wtcumref ON hits.referrerurl = wtcumref.refurl LEFT OUTER JOIN wtreferrercolor ON hits.referrerurl REGEXP wtreferrercolor.rcurl WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND visits.source != \'indexer\' AND visits.source != \'rss\' GROUP BY referrerurl ORDER BY hitcount DESC %[limitn]%'), -- 20180610
('rpt_referrer','query2','SELECT SUM(hits.txsize) AS tqb, COUNT(hits.referrerurl) AS tqh FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex LEFT OUTER JOIN wtcumref ON hits.referrerurl = wtcumref.refurl WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND visits.source != \'indexer\' AND visits.source != \'rss\''),
('rpt_referrerdom','query1','SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(hits.referrerurl,\'//\',-1),\'/\',1) AS refdom, SUM(hits.txsize) AS bytes, COUNT(hits.referrerurl) AS hitcount, MAX(wtcumref.refurl), MAX(wtreferrercolor.rcclass) FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex LEFT OUTER JOIN wtcumref ON hits.referrerurl = wtcumref.refurl LEFT OUTER JOIN wtreferrercolor ON hits.referrerurl REGEXP wtreferrercolor.rcurl WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND visits.source != \'indexer\' AND visits.source != \'rss\' GROUP BY refdom ORDER BY hitcount DESC %[limitn]%'),
('rpt_referrerdom','query2','SELECT SUM(hits.txsize) AS tqb, COUNT(hits.referrerurl) AS tqh FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex LEFT OUTER JOIN wtcumref ON hits.referrerurl = wtcumref.refurl WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND referrerurl != \'\' AND visits.source != \'indexer\' AND visits.source != \'rss\''),
('rpt_localquery','query1','SELECT hits.path, COUNT(hits.path) AS qh, hits.myquery FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE hits.myquery != \'\' AND wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NOT NULL GROUP BY hits.path, hits.myquery ORDER BY qh DESC'),
('rpt_localquery','query2','SELECT COUNT(hits.myquery) AS tqh FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NOT NULL AND hits.myquery != \'\''),

('rpt_attacks','query1','SELECT FROM_UNIXTIME(hits.systime) AS tim, hits.domain, hits.path AS hitp, hits.retcode, visits.htmlinvisit, visits.graphicsinvisit FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN visits ON vn=visitno WHERE wtretcodes.good != 0 AND FIND_IN_SET(hits.filename,\'%[rpt_attacks_watch]%\') AND ((visits.graphicsinvisit=0 AND visits.htmlinvisit=1) OR (visits.graphicsinvisit IS NULL))'),
('rpt_attacks','query2','SELECT FROM_UNIXTIME(hits.systime) AS tim, hits.domain, hits.path AS hitp, hits.filename AS hitfile, hits.retcode, visits.htmlinvisit, visits.graphicsinvisit FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN visits ON vn=visitno INNER JOIN wthackfilenames ON hits.path REGEXP hackfileregex WHERE wtretcodes.good != 0 ORDER BY systime'),
('rpt_attacks','query3','SELECT FROM_UNIXTIME(MAX(hits.systime)) AS tim, hits.domain, MAX(hits.path) AS hitp, MAX(hits.filename) AS hitfile, hits.retcode, MAX(visits.htmlinvisit), MAX(visits.graphicsinvisit), COUNT(*) AS nhit FROM hits LEFT OUTER JOIN visits ON vn=visitno INNER JOIN wthackfiletypes ON hits.filetype = wthackfiletypes.hackfiletype LEFT OUTER JOIN wtexpected404 ON hits.path REGEXP wtexpected404.f404 WHERE hits.retcode = \'404\' AND wtexpected404.f404 IS NULL GROUP BY hits.domain ORDER BY MAX(systime)'),
('rpt_attacks','query4','SELECT COUNT(*) AS nhit, hits.filename AS hitfile, hits.domain, MAX(hits.retcode) FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0 AND FIND_IN_SET(hits.filename,\'%[rpt_attacks_watchuse]%\') GROUP BY hits.filename, hits.domain ORDER BY nhit DESC'),
-- shellshock attacks
('rpt_attacks','query5','SELECT FROM_UNIXTIME(MAX(hits.systime)) AS tim, hits.domain, MAX(hits.path) AS hitp, MAX(hits.filename), MAX(hits.retcode), SUM(visits.htmlinvisit) AS nht, SUM(visits.graphicsinvisit) AS ngf, COUNT(*) AS nhit FROM hits LEFT OUTER JOIN visits ON vn=visitno WHERE hits.browser LIKE \'()%\' OR hits.referrerurl LIKE \'()%\' GROUP BY hits.domain ORDER BY hits.domain'),
('rpt_attacks','query6','SELECT FROM_UNIXTIME(MAX(hits.systime)) AS tim, hits.domain, MAX(hits.path) AS hitp, MAX(hits.filename), MAX(hits.retcode), SUM(visits.htmlinvisit) AS nht, SUM(visits.graphicsinvisit) AS ngf, COUNT(*) AS nhit FROM hits LEFT OUTER JOIN visits ON vn=visitno WHERE hits.browser LIKE \'%jndi%\' OR hits.referrerurl LIKE \'%jndi%\' OR hits.path LIKE \'%jndi%\' OR hits.path LIKE \'%:1389/Binary%\' OR hits.path LIKE \'%:1389/Exploit%\' GROUP BY hits.domain ORDER BY hits.domain'),
('rpt_retcode','query1','SELECT retcode, COUNT(hits.domain) AS hitcount, SUM(hits.txsize) AS bytesize, wtretcodes.meaning, wtretcodes.good FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code GROUP BY retcode ORDER BY retcode'),
('rpt_verb','query1','SELECT verb, COUNT(hits.domain) AS hitcount, SUM(hits.txsize) AS bytesize FROM hits GROUP BY verb ORDER BY hitcount DESC'),
-- printvisitdetail queries, will be expanded to do one hit slice at a time
('rpt_details','qpvd','SELECT $star, FROM_UNIXTIME(systime) AS stamp FROM hits INNER JOIN visits ON hits.vn = visits.visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf LEFT OUTER JOIN wtcolors ON hits.path REGEXP wtcolors.colfilename LEFT OUTER JOIN wtboring ON hits.path REGEXP wtboring.borfilename LEFT OUTER JOIN wtreferrercolor ON hits.referrerurl REGEXP wtreferrercolor.rcurl LEFT OUTER JOIN wtcumref ON hits.referrerurl = wtcumref.refurl LEFT OUTER JOIN wtdomhist ON visits.vdomain = wtdomhist.dhdom WHERE vn >= %[sllo]% AND vn <= %[slhi]% AND wtretcodes.good != 0 ORDER BY vn, sn'),
('rpt_details','qlog','SELECT logtime, logtext, FROM_UNIXTIME(logtime) AS logtimeformatted FROM wtlog WHERE logtime >= $firstdatebin AND logtime <= $lastdatebin'),
-- year report
('rpt_year_query','query1','SELECT query, SUM(querycnt) AS cnt, SUM(querybytes) AS bytes FROM wtcumquery GROUP BY query ORDER BY querycnt DESC %[limitn]%'),
('rpt_year_query','query2','SELECT COUNT(*) AS tq, SUM(querycnt) AS tqh, SUM(querybytes) AS tqb FROM wtcumquery'),
('rpt_day_words','query1','SELECT word, wcount FROM wtdquerywords ORDER BY wcount DESC %[limitn]%'),
('rpt_day_words','query2','SELECT COUNT(*) AS tw, SUM(wcount) AS twc FROM wtdquerywords'),
('rpt_year_words','query1','SELECT word, wcount FROM wtyquerywords ORDER BY wcount DESC %[limitn]%'),
('rpt_year_words','query2','SELECT COUNT(*) AS tw, SUM(wcount) AS twc FROM wtyquerywords'),
('rpt_year_referrer','query1','SELECT SUBSTRING_INDEX(TRIM(LEADING "www." FROM TRIM(LEADING "https://" FROM TRIM(LEADING "http://" FROM TRIM(refurl)))),"/",1) AS refdom, SUM(refcnt) AS hits, SUM(refbytes) AS bytes, MAX(wtreferrercolor.rcclass) FROM  wtcumref LEFT OUTER JOIN wtreferrercolor ON refurl REGEXP wtreferrercolor.rcurl WHERE refwithquery=0 GROUP BY refdom ORDER BY hits DESC %[limitn]%'),
('rpt_year_referrer','query2','SELECT SUM(refcnt) AS tqh, SUM(refbytes) AS tqb FROM wtcumref WHERE refwithquery = 0'),
('rpt_year_domain','query1','SELECT dhdom, dhhits, dhhtm, dhgrf, dhbytes, DATEDIFF(\'%[lastdate]%\', dhlast) AS dslv, dhdays, dhvisits FROM wtdomhist ORDER BY dhhits DESC %[limitn]%'),
('rpt_dslv_domain','query1','SELECT x.b AS dslv, COUNT(x.a) AS ndoms FROM (SELECT DATEDIFF(\'%[lastdate]%\', dhlast) AS b, dhdom AS a FROM wtdomhist) AS x GROUP BY dslv ORDER BY dslv %[limitn]%'),
('rpt_dslv_domain','query1m','SELECT MAX(y.ndoms) AS maxdoms FROM (SELECT x.b AS dslv, COUNT(x.a) AS ndoms FROM (SELECT DATEDIFF(\'%[lastdate]%\', dhlast) AS b, dhdom AS a FROM wtdomhist) AS x GROUP BY dslv) AS y'),
-- hmm we dont have the directory here
('rpt_cumpage','query1','SELECT ffilename, ffilecnt, SUM(ffilebytes) AS bytes, sufclass, MAX(wtcolors.colorclass) FROM wtcumfile INNER JOIN wtsuffixclass ON ffilename REGEXP CONCAT(suf, \'$\') LEFT OUTER JOIN wtcolors ON ffilename REGEXP wtcolors.colfilename WHERE wtsuffixclass.sufclass = \'html\' GROUP BY ffilename ORDER BY ffilecnt DESC %[limitn]%'),
('rpt_bymonth','query1','SELECT MONTH(FROM_UNIXTIME(wtdayhist.dbegtimebin)) AS m, SUM(dhits) AS h, SUM(dhtmlpages) AS hh, SUM(dgraphicpages) AS hg, SUM(dbytes) AS b, SUM(dvisits) AS v FROM wtdayhist WHERE ((UNIX_TIMESTAMP() - wtdayhist.dbegtimebin) < 31*24*60*60) OR ((MONTH(FROM_UNIXTIME(wtdayhist.dbegtimebin)) != MONTH(CURRENT_DATE())) AND ((UNIX_TIMESTAMP() - wtdayhist.dbegtimebin) < 366*24*60*60)) GROUP BY m ORDER BY MAX(wtdayhist.dbegtimebin)'),
('rpt_bymonth','query1m','SELECT MAX(x.h) AS mx FROM (SELECT MONTH(FROM_UNIXTIME(wtdayhist.dbegtimebin)) AS m, SUM(dhits) AS h FROM wtdayhist WHERE ((UNIX_TIMESTAMP() - wtdayhist.dbegtimebin) < 31*24*60*60) OR ((MONTH(FROM_UNIXTIME(wtdayhist.dbegtimebin)) != MONTH(CURRENT_DATE())) AND ((UNIX_TIMESTAMP() - wtdayhist.dbegtimebin) < 366*24*60*60)) GROUP BY m) AS x'),
('rpt_paths','query1','SELECT hits.referrerurl, hits.path, hits.txsize FROM hits INNER JOIN visits ON vn = visitno WHERE visitclass != \'indexer\' AND hits.referrerurl REGEXP \'%[rpt_paths_trimref]%\' AND hits.filetype = \'html\' ORDER BY hits.referrerurl, hits.path'),
('rpt_byyear','query1','SELECT SUBSTR(FROM_UNIXTIME(dbegtimebin),1,4) AS cumyear, SUM(dhits) AS cumhits, SUM(dbytes) AS cumbytes, SUM(dvisits) AS cumvisits, SUM(dhtmlpages) AS cumhtmlpages, SUM(dgraphicpages) AS cumgraphicpages, SUM(dtotalreckb) AS cumtotalreckb, SUM(dtotalrecs) AS cumtotalrecs, SUM(dhtmlfiles) AS cumhtmlfiles, SUM(dhtmlbytes) AS cumhtmlbytes, SUM(dgraphicbytes) AS cumgraphicbytes, SUM(dnlinkhits) AS cumnlinkhits, SUM(dnlinkvisits) AS cumnlinkvisits, SUM(dlinkbytes) AS cumlinkbytes, SUM(dnsearches) AS cumnsearches, SUM(dnsearchvisits) AS cumnsearchvisits, SUM(dsearchbytes) AS cumsearchbytes, SUM(dnheadp) AS cumnheadp, SUM(dhphits) AS cumhphits, SUM(dhpbytes) AS cumhpbytes, SUM(dnohtmlvisits) AS cumnohtmlvisits, SUM(dnohtmlvisitshits) AS cumnohtmlvisitshits, SUM(dnohtmlbytes) AS cumnohtmlbytes, SUM(dhtmlvisits) AS cumhtmlvisits, SUM(dindexhits) AS cumindexhits, SUM(dnindexvisits) AS cumnindexvisits, SUM(dindexbytes) AS cumindexbytes, SUM(dndomainstoday) AS cumndomainstoday, SUM(dnewdomainstoday) AS cumnewdomainstoday, SUM(dhitsnovisit) AS cumhitsnovisit, SUM(ddomsnovisit) AS cumdomsnovisit, COUNT(*) AS cumdays FROM wtdayhist GROUP BY SUBSTR(FROM_UNIXTIME(dbegtimebin),1,4) ORDER BY cumyear DESC'),
('rpt_byyear','query2','SELECT SUM(dhits) AS cumthits, SUM(dbytes) AS cumtbytes, SUM(dvisits) AS cumtvisits, SUM(dhtmlpages) AS cumthtmlpages, SUM(dgraphicpages) AS cumtgraphicpages FROM wtdayhist'),
('rpt_byyear','query3','SELECT MAX(x) AS hitscale FROM (SELECT SUM(dhits) AS x FROM wtdayhist GROUP by SUBSTR(FROM_UNIXTIME(dbegtimebin),1,4)) AS iw'),
('rpt_paths','query2','SELECT * FROM wtcumpath WHERE cfrom != cto ORDER BY ccnt DESC limit %[rpt_paths_trim]%'),
-- report on geolocation (non indexer sites)
-- ('rpt_geoloc','query1','SELECT TRIM(TRAILING \']\' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(vdomain,\'[\',-1), \'/\', 1)) AS cc, countrynames.cnname, countrynames.cncontinent, TRIM(TRAILING \']\' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(vdomain,\'[\',-1), \'/\', -1)) AS city, COUNT(vdomain) AS nv FROM visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE INSTR(vdomain,\']\') > 0 AND visits.visitclass != \'indexer\' GROUP BY city ORDER BY nv DESC %[limitn]%'),
('rpt_geoloc','query1','SELECT TRIM(TRAILING \']\' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(MAX(visits.vdomain),\'[\',-1), \'/\', 1)) AS cc, MAX(countrynames.cnname) AS xcnname, MAX(countrynames.cncontinent) AS xcncontinent, TRIM(TRAILING \']\' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(MAX(visits.vdomain),\'[\',-1), \'/\', -1)) AS city, MAX(x.vno) AS nv, COUNT(visits.vdomain) AS hcvc, wtvclasses.vbarcolor, visitclass FROM visits INNER JOIN (SELECT TRIM(TRAILING \']\' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(vdomain,\'[\',-1), \'/\', -1)) AS cityz, COUNT(visitno) AS vno FROM visits WHERE INSTR(vdomain,\']\') > 0 AND visits.visitclass != \'indexer\' GROUP BY cityz ORDER BY vno DESC %[limitn]%) AS x ON cityz = TRIM(TRAILING \']\' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(visits.vdomain,\'[\',-1), \'/\', -1)) INNER JOIN wtvclasses ON visits.visitclass = wtvclasses.vclass LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE INSTR(visits.vdomain,\']\') > 0 AND visits.visitclass != \'indexer\' GROUP BY SUBSTRING_INDEX(SUBSTRING_INDEX(vdomain,\'[\',-1), \'/\', -1), visitclass ORDER BY nv DESC, city, visitclass'),
('rpt_geoloc','legendquery','SELECT * FROM  wtvclasses ORDER BY vclass'),
-- report on repeated hits (non indexers, real hits only)
('rpt_repeat','query1','SELECT COUNT(*) AS nhits, MAX(hits.path) AS hp, hits.filename, hits.domain, MAX(visits.browsername) AS bn FROM hits INNER JOIN visits ON hits.vn = visits.visitno WHERE visitclass != \'indexer\' AND hits.retcode=\'200\' GROUP BY filename, domain ORDER BY nhits DESC %[limitn]%'),
-- SELECT COUNT(*) AS nhit, hits.filename, hits.domain, hits.retcode, visits.visitclass FROM hits  INNER JOIN visits ON hits.vn = visits.visitno WHERE NOT FIND_IN_SET(hits.filename,'favicon.ico,tinyglob.gif') AND NOT FIND_IN_SET(visits.visitclass,'indexer,rss') AND retcode='200' GROUP BY filename, domain ORDER BY nhit DESC %[limitn]%
--
('update_wtcumquery','up','INSERT INTO wtcumquery(query, querycnt, querybytes) SELECT hits.referrerquery, 1, hits.txsize FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND hits.referrerquery != \'\' ON DUPLICATE KEY UPDATE querycnt=querycnt+1, querybytes=querybytes+txsize'),
('update_wtcumref','up','INSERT INTO wtcumref(refurl, refcnt, refbytes, refwithquery) SELECT hits.referrerurl, 1, hits.txsize, (hits.referrerquery != \'\') FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtlocalreferrerregexp ON hits.referrerurl REGEXP wtlocalreferrerregexp.regex WHERE wtretcodes.good != 0 AND wtlocalreferrerregexp.regex IS NULL AND hits.referrerurl != \'\' ON DUPLICATE KEY UPDATE refcnt=refcnt+1, refbytes=refbytes+txsize, refwithquery=refwithquery+(referrerquery != \'\')'),
('update_wtdomhist','up','INSERT INTO wtdomhist(dhdom, dhfirst, dhlast, dhdays, dhvisits, dhhits, dhhtm, dhgrf, dhbytes) SELECT visits.vdomain, DATE(FROM_UNIXTIME(hits.systime)), DATE(FROM_UNIXTIME(hits.systime)), 1, 1, visits.ninvisit, visits.htmlinvisit, visits.graphicsinvisit, visits.bytesinvisit FROM hits INNER JOIN visits ON hits.vn = visits.visitno WHERE hits.sn=0 AND visits.vdomain != \'\' ON DUPLICATE KEY UPDATE dhdays=dhdays+(DATEDIFF(DATE(FROM_UNIXTIME(hits.systime)), dhlast) > 0), dhfirst=LEAST(dhfirst,DATE(FROM_UNIXTIME(hits.systime))), dhlast=GREATEST(dhlast,DATE(FROM_UNIXTIME(hits.systime))), dhvisits=dhvisits+1, dhhits=dhhits+visits.ninvisit, dhhtm=dhhtm+visits.htmlinvisit, dhgrf=dhgrf+visits.graphicsinvisit, dhbytes=dhbytes+visits.bytesinvisit'),
('update_wtcumfile','up','INSERT INTO wtcumfile(ffilename, ffilecnt, ffilebytes) SELECT hits.filename, 1, hits.txsize FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good=1 ON DUPLICATE KEY UPDATE ffilecnt=ffilecnt+1, ffilebytes=ffilebytes+txsize'),
('update_wtfilehist','up','INSERT INTO wtfilehist(ffilepath, ffilecnt, ffilebytes, ffnicnt, ffnibytes, fffirst, fflast) SELECT hits.path, 1, hits.txsize, (visits.source! = \'indexer\'), hits.txsize*(visits.source != \'indexer\'), hits.systime, hits.systime FROM hits INNER JOIN visits ON vn = visitno INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good = 1 ON DUPLICATE KEY UPDATE ffilecnt=ffilecnt+1, ffilebytes=ffilebytes+txsize, ffnicnt=ffnicnt+(visits.source != \'indexer\'), ffnibytes=ffnibytes+(txsize*(visits.source != \'indexer\')), fflast=hits.systime'),
('update_wtcumgoog','up','INSERT INTO wtcumgoog(lgpath,lgcrawls,lgbytes,lgfirst,lglast) SELECT hits.path, 1, hits.txsize, hits.systime, hits.systime FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code WHERE wtretcodes.good != 0 AND (hits.domain LIKE \'%googlebot.com\' OR hits.domain LIKE \'%googlebot.com[us%\') ON DUPLICATE KEY UPDATE lgcrawls=lgcrawls+1, lgbytes=lgbytes+hits.txsize, lglast=hits.systime'),
--
('trim_wtcumquery','trim','DELETE FROM wtcumquery WHERE querycnt < $cumquerycntmin AND querybytes < $cumquerybytemin'), -- we don't have dates
('trim_wtdomhist','trim','DELETE FROM wtdomhist WHERE DATEDIFF(CURRENT_DATE(), dhlast) > $ndomhistdays');

-- pie chart definitions
-- originally generated by pies.htmt and then hand tweaked
-- user can override the long and short weights
DROP TABLE IF EXISTS wtpiequeries;
CREATE TABLE wtpiequeries(
 tablecode char(3),      -- report code, e.g. NWO
 longweight char(3),     -- long report weight
 shortweight char(3), 	 -- short report weight
 byvarvar varchar(32), 	 -- where the x answer is bound
 scalevalue varchar(15), -- scale factor
 units varchar(32), 	 -- display for units
 title VARCHAR(255),	 -- title
 qvalue TEXT, 	     	 -- query
 PRIMARY KEY(tablecode)
);
INSERT INTO wtpiequeries VALUES
('NWO','050','000','countrynames.x','1','','NI Views by Continent','SELECT countrynames.cncontinent AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NWT','050','000','visits.x','1','','NI Views by Country','SELECT visits.tld AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NWY','050','000','visits.x','1','','NI Views by City','SELECT visits.city AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NWF','000','000','wtsuffixclass.x','1','','NI Views by Filetype','SELECT wtsuffixclass.sufclass AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('NWC','050','000','visits.x','1','','NI Views by Class','SELECT visits.visitclass AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NWR','050','000','visits.x','1','','NI Views by Browser','SELECT visits.browsertype AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NWP','050','000','visits.x','1','','NI Views by Platform','SELECT visits.platformtype AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NWS','050','000','visits.x','1','','NI Views by Source','SELECT visits.source AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVO','050','060','countrynames.x','1','','NI Visits by Continent','SELECT countrynames.cncontinent AS x, COUNT(visits.visitno) AS v FROM visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVT','060','000','visits.x','1','','NI Visits by Country','SELECT visits.tld AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVY','050','000','visits.x','1','','NI Visits by City','SELECT visits.city AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVF','050','000','.x','1','','NI Visits by Filetype','SELECT CASE WHEN (visits.htmlinvisit > 0) AND (visits.graphicsinvisit > 0) THEN \'mixed\' WHEN (visits.htmlinvisit = 0) THEN \'nohtml\' ELSE \'nographic\' END AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- special case
('NVC','050','000','visits.x','1','','NI Visits by Class','SELECT visits.visitclass AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVR','120','080','visits.x','1','','NI Visits by Browser','SELECT visits.browsertype AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVP','110','070','visits.x','1','','NI Visits by Platform','SELECT visits.platformtype AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NVS','050','000','visits.x','1','','NI Visits by Source','SELECT visits.source AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHO','050','000','countrynames.x','1','','NI Hits by Continent','SELECT countrynames.cncontinent AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHT','070','000','visits.x','1','','NI Hits by Country','SELECT visits.tld AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHY','050','000','visits.x','1','','NI Hits by City','SELECT visits.city AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHF','090','000','wtsuffixclass.x','1','','NI Hits by Filetype','SELECT wtsuffixclass.sufclass AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits, wtsuffixclass WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND wtsuffixclass.suf = hits.filetype AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHC','050','000','visits.x','1','','NI Hits by Class','SELECT visits.visitclass AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHR','050','000','visits.x','1','','NI Hits by Browser','SELECT visits.browsertype AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHP','050','000','visits.x','1','','NI Hits by Platform','SELECT visits.platformtype AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NHS','050','000','visits.x','1','','NI Hits by Source','SELECT visits.source AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBO','050','000','countrynames.x','1048576',' MB','NI MB by Continent','SELECT countrynames.cncontinent AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBT','051','000','visits.x','1048576',' MB','NI MB by Country','SELECT visits.tld AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBY','050','000','visits.x','1048576',' MB','NI MB by City','SELECT visits.city AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBF','080','000','wtsuffixclass.x','1048576',' MB','NI MB by Filetype','SELECT wtsuffixclass.sufclass AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits, wtsuffixclass WHERE hits.vn = visits.visitno AND wtsuffixclass.suf = hits.filetype AND visits.source != \'indexer\' AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('NBC','050','000','visits.x','1048576',' MB','NI MB by Class','SELECT visits.visitclass AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBR','050','000','visits.x','1048576',' MB','NI MB by Browser','SELECT visits.browsertype AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBP','050','000','visits.x','1048576',' MB','NI MB by Platform','SELECT visits.platformtype AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('NBS','050','000','visits.x','1048576',' MB','NI MB by Source','SELECT visits.source AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source != \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWO','050','000','countrynames.x','1','','Views by Continent','SELECT countrynames.cncontinent AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWT','050','000','visits.x','1','','Views by Country','SELECT visits.tld AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWY','050','000','visits.x','1','','Views by City','SELECT visits.city AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWF','000','000','wtsuffixclass.x','1','','Views by Filetype','SELECT wtsuffixclass.sufclass AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('AWC','050','000','visits.x','1','','Views by Class','SELECT visits.visitclass AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWR','050','000','visits.x','1','','Views by Browser','SELECT visits.browsertype AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWP','050','000','visits.x','1','','Views by Platform','SELECT visits.platformtype AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AWS','050','000','visits.x','1','','Views by Source','SELECT visits.source AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVO','100','000','countrynames.x','1','','Visits by Continent','SELECT countrynames.cncontinent AS x, COUNT(visits.visitno) AS v FROM visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVT','160','000','visits.x','1','','Visits by Country','SELECT visits.tld AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVY','050','000','visits.x','1','','Visits by City','SELECT visits.city AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVF','050','000','.x','1','','Visits by Filetype','SELECT CASE WHEN (visits.htmlinvisit > 0) AND (visits.graphicsinvisit > 0) THEN \'mixed\' WHEN (visits.htmlinvisit = 0) THEN \'nohtml\' ELSE \'nographic\' END AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'), -- special case
('AVC','130','090','visits.x','1','','Visits by Class','SELECT visits.visitclass AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVR','050','000','visits.x','1','','Visits by Browser','SELECT visits.browsertype AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVP','050','000','visits.x','1','','Visits by Platform','SELECT visits.platformtype AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AVS','140','000','visits.x','1','','Visits by Source','SELECT visits.source AS x, COUNT(visits.visitno) AS v FROM visits WHERE 1=1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHO','050','000','countrynames.x','1','','Hits by Continent','SELECT countrynames.cncontinent AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHT','170','000','visits.x','1','','Hits by Country','SELECT visits.tld AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHY','050','000','visits.x','1','','Hits by City','SELECT visits.city AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHF','190','000','wtsuffixclass.x','1','','Hits by Filetype','SELECT wtsuffixclass.sufclass AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits, wtsuffixclass WHERE hits.vn = visits.visitno AND wtsuffixclass.suf = hits.filetype AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('AHC','050','000','visits.x','1','','Hits by Class','SELECT visits.visitclass AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHR','050','000','visits.x','1','','Hits by Browser','SELECT visits.browsertype AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHP','050','000','visits.x','1','','Hits by Platform','SELECT visits.platformtype AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('AHS','050','000','visits.x','1','','Hits by Source','SELECT visits.source AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABO','050','000','countrynames.x','1048576',' MB','MB by Continent','SELECT countrynames.cncontinent AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABT','150','000','visits.x','1048576',' MB','MB by Country','SELECT visits.tld AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABY','050','000','visits.x','1048576',' MB','MB by City','SELECT visits.city AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABF','180','060','wtsuffixclass.x','1048576',' MB','MB by Filetype','SELECT wtsuffixclass.sufclass AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits, wtsuffixclass WHERE hits.vn = visits.visitno AND wtsuffixclass.suf = hits.filetype AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('ABC','050','000','visits.x','1048576',' MB','MB by Class','SELECT visits.visitclass AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABR','050','000','visits.x','1048576',' MB','MB by Browser','SELECT visits.browsertype AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABP','050','000','visits.x','1048576',' MB','MB by Platform','SELECT visits.platformtype AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('ABS','050','000','visits.x','1048576',' MB','MB by Source','SELECT visits.source AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWO','050','000','countrynames.x','1','','Ix Views by Continent','SELECT countrynames.cncontinent AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWT','050','000','visits.x','1','','Ix Views by Country','SELECT visits.tld AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWY','050','000','visits.x','1','','Ix Views by City','SELECT visits.city AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWF','000','000','wtsuffixclass.x','1','','Ix Views by Filetype','SELECT wtsuffixclass.sufclass AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('IWC','000','000','visits.x','1','','Ix Views by Class','SELECT visits.visitclass AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWR','000','000','visits.x','1','','Ix Views by Browser','SELECT visits.browsertype AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWP','000','000','visits.x','1','','Ix Views by Platform','SELECT visits.platformtype AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IWS','000','000','visits.x','1','','Ix Views by Source','SELECT visits.source AS x, COUNT(visits.visitno) AS v FROM hits, wtretcodes, wtsuffixclass, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND hits.filetype = wtsuffixclass.suf AND wtsuffixclass.sufclass = \'html\' AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVO','000','000','countrynames.x','1','','Ix Visits by Continent','SELECT countrynames.cncontinent AS x, COUNT(visits.visitno) AS v FROM visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVT','050','000','visits.x','1','','Ix Visits by Country','SELECT visits.tld AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVY','050','000','visits.x','1','','Ix Visits by City','SELECT visits.city AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVF','050','000','.x','1','','Ix Visits by Filetype','SELECT CASE WHEN (visits.htmlinvisit > 0) AND (visits.graphicsinvisit > 0) THEN \'mixed\' WHEN (visits.htmlinvisit = 0) THEN \'nohtml\' ELSE \'nographic\' END AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- speical case
('IVC','000','000','visits.x','1','','Ix Visits by Class','SELECT visits.visitclass AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVR','000','000','visits.x','1','','Ix Visits by Browser','SELECT visits.browsertype AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVP','000','000','visits.x','1','','Ix Visits by Platform','SELECT visits.platformtype AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IVS','000','000','visits.x','1','','Ix Visits by Source','SELECT visits.source AS x, COUNT(visits.visitno) AS v FROM visits WHERE visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHO','000','000','countrynames.x','1','','Ix Hits by Continent','SELECT countrynames.cncontinent AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHT','050','000','visits.x','1','','Ix Hits by Country','SELECT visits.tld AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHY','050','000','visits.x','1','','Ix Hits by City','SELECT visits.city AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHF','050','000','wtsuffixclass.x','1','','Ix Hits by Filetype','SELECT wtsuffixclass.sufclass AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits, wtsuffixclass WHERE hits.vn = visits.visitno AND wtsuffixclass.suf = hits.filetype AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('IHC','000','000','visits.x','1','','Ix Hits by Class','SELECT visits.visitclass AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHR','000','000','visits.x','1','','Ix Hits by Browser','SELECT visits.browsertype AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHP','000','000','visits.x','1','','Ix Hits by Platform','SELECT visits.platformtype AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IHS','000','000','visits.x','1','','Ix Hits by Source','SELECT visits.source AS x, COUNT(hits.domain) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBO','050','000','countrynames.x','1048576',' MB','Ix MB by Continent','SELECT countrynames.cncontinent AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits LEFT OUTER JOIN countrynames ON visits.tld = countrynames.cncode WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBT','050','000','visits.x','1048576',' MB','Ix MB by Country','SELECT visits.tld AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBY','050','000','visits.x','1048576',' MB','Ix MB by City','SELECT visits.city AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBF','050','000','wtsuffixclass.x','1048576',' MB','Ix MB by Filetype','SELECT wtsuffixclass.sufclass AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits, wtsuffixclass WHERE hits.vn = visits.visitno AND wtsuffixclass.suf = hits.filetype AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'), -- fixed
('IBC','000','000','visits.x','1048576',' MB','Ix MB by Class','SELECT visits.visitclass AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBR','000','000','visits.x','1048576',' MB','Ix MB by Browser','SELECT visits.browsertype AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBP','000','000','visits.x','1048576',' MB','Ix MB by Platform','SELECT visits.platformtype AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15'),
('IBS','000','000','visits.x','1048576',' MB','Ix MB by Source','SELECT visits.source AS x, SUM(hits.txsize) AS v FROM hits, wtretcodes, visits WHERE hits.vn = visits.visitno AND hits.retcode = wtretcodes.code AND wtretcodes.good = 1 AND visits.source = \'indexer\' GROUP BY x ORDER BY v DESC LIMIT 15');

-- One row per global variable calculated from the data by heading queries
-- -- this table is used by ggq.htmt to generate an htmt file
-- -- which in turn generates wtglobals.sh
-- -- this is so that adding a new global does not require editing a template, it's all in SQL
-- -- To add a new global, add a row here and a query in wtqueries for 'rpt_heading'
DROP TABLE IF EXISTS wtglobvar;
CREATE TABLE wtglobvar(
 gvname VARCHAR(32) PRIMARY KEY, -- globar var name
 gvquery VARCHAR(32),            -- the query that generates the value
 gvqueryvar VARCHAR(32),         -- the varname in the query
 gvfactor VARCHAR(32)            -- 1, 1024, or 1048576
);
INSERT INTO wtglobvar VALUES
('totalrecs','qtrec','.total','1'),
('totalreckb','qtrec','.bytes','1024'),
('totalhits','qtb','.total','1'),
('totalbytes','qtb','.bytes','1'),
('totalkb','qtb','.bytes','1024'),
('totalmb','qtb','.bytes','1048576'),
('totalhitsni','qtbni','.total','1'),
('totalbytesni','qtbni','.bytes','1'),
('totalkbni','qtbni','.bytes','1024'),
('totalmbni','qtbni','.bytes','1048576'),
('firstdatebin','qmintb','.first','1'),
('firstdate','qminta','.first','1'),
('lastdatebin','qmaxtb','.last','1'),
('lastdate','qmaxta','.last','1'),
('totalvisits','qtv','.total','1'),
('totalvisitsni','qtvni','.total','1'),
('totalauthkb','qauthkb','.total','1024'),
('totalauthhits','qauthhits','.total','1'),
('totalauthids','qauthids','.total','1'),
('totalauthsess','qauthsess','.total','1'),
('htmlhits','qhtml','.total','1'),
('htmlbytes','qhtml','.bytes','1'),
('htmlkb','qhtml','.bytes','1024'),
('htmlhitsni','qhtmlni','.total','1'),
('htmlbytesni','qhtmlni','.bytes','1'),
('htmlkbni','qhtmlni','.bytes','1024'),
('graphichits','qgraphic','.total','1'),
('graphicbytes','qgraphic','.bytes','1'),
('graphichitsni','qgraphicni','.total','1'),
('graphicbytesni','qgraphicni','.bytes','1'),
('htmlfiles','qhtmlfiles','.n','1'),
('htmlfilesni','qhtmlfilesni','.n','1'),
('ytotalhits','qytothits','.ytothits','1'),
('ytotalbytes','qytothits','.ytotbytes','1'),
('ytotalkb','qytothits','.ytotbytes','1024'),
('yhtotalhits','qyhtothits','.ytothits','1'),
('yhtotalbytes','qyhtothits','.ytotbytes','1'),
('yhtotalkb','qyhtothits','.ytotbytes','1024'),
('nlinkhits','qlink','.linkhits','1'),
('nlinkvisits','qlink','.nlinkvisits','1'),
('linkbytes','qlink','.linkbytes','1'),
('nsearches','qsearch','.nsearches','1'),
('nsearchvisits','qsearch2','.nsearchvisits','1'),
('searchbytes','qsearch2','.searchbytes','1'),
('nheadp','qnhp','.nheadp','1'),
('hphits','qhp','.hphits','1'),
('hpbytes','qhp','.hpbytes','1'),
('nohtmlvisits','qzhtml','.x','1'),
('nohtmlvisitshits','qzhtml','.y','1'),
('nohtmlbytes','qzhtml','.z','1'),
('htmlvisits','qnzhtml','.x','1'),
('htmlvisitsni','qnzhtmlni','.x','1'),
('indexhits','qindex','.indexhits','1'),
('nindexvisits','qindex','.nindexvisits','1'),
('indexbytes','qindex','.indexbytes','1'),
('ndomainstoday','qndomains','.n','1'),
('newdomainstoday','qnewdomains','.n','1'),
('ntld','qntld','.n','1'),
('nbrowser','qnbrow','.n','1'),
('nreferrer','qnrefer','.n','1'),
('nquery','qnquery','.n','1'),
('nengine','qnengine','.n','1'),
('nvisitclass','qnclasses','.n','1'),
('ydomain','qydomain','.n','1'),
('yfile','qyfile','.n','1'),
('yhfile','qyhfile','.n','1'),
('yreferrer','qyreferrer','.n','1'),
('hitsnovisit','qhitsnovisit','.n','1'),
('domsnovisit','qdomsnovisit','.n','1'),
('n404','q404','.n','1'),
('dayhistfirst','qdayhistfirst','.x','1'),
('domhistfirst','qdomhistfirst','.x','1'),
('ngoogletoday','qngoogletoday','.totgoo','1'),
('googlecrawldate','qgooglecrawldate','.x','1'),
('nnevergooglehtml','qnnevergooglehtml','.x','1');
-- end
-- ================================================================
--  Permission is hereby granted, free of charge, to any person obtaining 
--  a copy of this software and associated documentation files (the 
--  "Software"), to deal in the Software without restriction, including 
--  without limitation the rights to use, copy, modify, merge, publish, 
--  distribute, sublicense, and/or sell copies of the Software, and to 
--  permit persons to whom the Software is furnished to do so, subject to 
--  the following conditions: 
-- 
--  The above copyright notice and this permission notice shall be included 
--  in all copies or substantial portions of the Software. 
-- 
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
--  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
--  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
--  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
--  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
--  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
--  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
-- ================================================================
