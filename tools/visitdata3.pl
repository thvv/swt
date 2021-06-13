#\!/usr/local/bin/perl
#
# Copyright 2006-2019, Tom Van Vleck
#
# Usage:
#   export visitdata_vq="SELECT * FROM hits INNER JOIN wtretcodes ON hits.retcode=wtretcodes.code WHERE wtretcodes.good=1 ORDER BY vn, sn"
#   visitdata -config configfile.htmi > visits.sql
#
# Reads a "hits" database constructed from the web server log. 
#    environment variable "visitdata_vq" is the query.
# Writes SQL input that creates one record per visit.
# .. a visit is a sequence of hits (cached and partials count)
#
# The SQL file drops the whole visits table and re-creates it every time.
# Somewhat denormalized to make queries simpler: some data could be calculated by a join on hits.
#
# Determines browser ID, browser type, platform type, and TLD for the visit.
# Determines a "visitclass" for the visit as a function of the page classes of all pages in the visit.
# Determines the "source" of the visit.
# (tricky: browser type, visitclass, and source can be "indexer")
#
# Reading all hits in one big SELECT was blowing out memory with the return values.
# logvisits.pl computes a table, hitslices, that breaks the hits into slices.
# 
# Uses the following tables of configuration items from the database (see swt.sql)
#    wtlocalreferrerregexp, wtrobotdomains, wtheadpages, wtindexers, wtpclasses
#
# 04/20/06 THVV
# 06/15/06 THVV 1.1 accept geoip domains
# 07/21/06 THVV 1.11 accept geoip even if not numeric
# 09/10/06 THVV 1.2 detect "reference spam" and set a different source
# 09/21/06 THVV 1.21 change refspam thresh to 4
# 10/17/06 THVV 1.22 recognize some odd case browsers
# 11/25/06 THVV 1.23 set source = refspam if browser == user_agent != ''
# 11/26/06 THVV 1.3 set entrypage and exitpage
# 12/20/06 THVV 1.4 tighten up referrer spam detector, set thresh to 2
# 01/05/07 THVV 1.5 use hitslices, generate visit slices
# 02/08/07 THVV 1.51 add -config
# 04/30/07 THVV 1.52 handle super geoip with city, set in logextractor
# 07/27/07 THVV 1.6 Change wtindexers to hold multiple browser types
# 11/15/07 THVV 1.61 Change assign_source to ensure that indexer sessions are recognized
# 12/09/07 THVV 1.62 fix bug if there are exactly rowlimit hits
# 12/27/07 THVV 1.7 add authid
# 09/18/08 THVV 1.71 make visitdata_refspamthresh a parameter
# 09/18/08 THVV 1.72 fix bug in last slice
# 03/20/09 THVV 1.8 try to handle iPod, iPhone, and other new browsers
# 09/28/09 THVV 1.81 check visit source from domain only once per visit
# 04/18/11 THVV 1.82 recognize IPV6 as numeric
# 05/24/11 THVV 1.83 correct ttld for numeric
# 07/02/11 THVV 1.84 add iPad
# 03/10/12 THVV 1.85 hack to mark visits from .ru and .ua as refspam, most of em are
# 01/05/14 THVV 1.9 recognize android
# 03/13/15 THVV 1.91 refspam was not being recognized
# 10/10/15 THVV 1.92 detect misbehaving indexers
# 01/04/16 THVV 1.93 better detection for MSIE 9-10-11 and Edge, other userAgent tuning
# 04/04/16 THVV 2.0 add watch list processing
# 06/14/17 THVV 2.1 tweak refspam for .ru domains
# 07/27/17 THVV 2.2 change pageclass assignment to allow pathnames that do not begin with /
# 05/25/18 THVV 2.21 change pageclass assignment to not loop on pathnames that do not contain /
# 08/24/18 THVV 2.22 never generate a 'tld' value that is > 16 chars: it will crash MySQL load
# 07/01/19 THVV 2.23 never generate a 'browsername' or 'vdomain' value that is > 255 chars: it will crash MySQL load
# 06/11/21 THVV 2.24 expandfile3 => expandfile

#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
 
#  The above copyright notice and this permission notice shall be included
#  in all copies or substantial portions of the Software.
 
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

use DBI;
use expandfile;

$me = 'visitdata.pl';
$v{'me'} = 'visitdata.pl';
$version = '2.24';
$v{'sqlrowlimit'} = 1000;		# max number of rows for one INSERT

# Data for detect_browser()
# order is significant here, can't load from SQL without sorting, who cares, these don't change much
@platforms = ("Win95", "Win98", "Win9x", "WinNT", "Win32", "Windows 98", "Windows 95", "Windows 9x", "Windows NT", "Windows 2000",
	      "Windows Me", "Windows XP", "Windows", "Mac", "Linux", "FreeBSD", "OS/2", "Unix", "Win16", "Android");
@browser_types = ("Edge", "Trident", "MSIE", "Lynx", "Java", "Konqueror", "Opera", "Chrome", "Safari", "Mozilla");
$pageclass{'.'} = '';
%watchlistdom = ();	# empty watch list
%watchlistbrw = ();

if ($#ARGV < 0) {
    die "$me: too few arguments. Usage: $me -e config";
}

$configName = '';
while ($#ARGV >= 0) {
    $arg = shift;
    if ($arg eq "-config") {
	$configName = shift;
    } elsif ($arg eq "-e") {
	$configName = shift;
    } else {
	die "$me: invalid argument $arg";
    }
}
if ($configName eq '') {
    die "Usage: $me -config config";
}

$q = $ENV{'visitdata_vq'};
die "$me: visitdata_vq not set in environment" if $q eq '';

$refspamthresh = 2;		# 2 allows for users who link us from their blog and test it.
$refspamthresh = $ENV{'visitdata_refspamthresh'} if defined($ENV{'visitdata_refspamthresh'});

my $c = &loadfile($configName, \%v);
$v{'_xf_currentfilename'} = $configName;
$junk = &expandstring($c, \%v);
die "$me: $configName did not set hostname" if $v{'_xf_hostname'} eq '';

# Open the database
if (!($db = DBI->connect("DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}", $v{'_xf_username'}, $v{'_xf_password'}))) {
    print "$me: cannot open DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}, $v{'_xf_username'}\n";
    exit(0);
}

# load in the list of local referrers
@localdomregex = &loadtable('wtlocalreferrerregexp', 'regex');
@robotdomains = &loadtable('wtrobotdomains', 'dom');
@headpages = &loadtable('wtheadpages', 'headpage');
&loadhash('wtindexers', 'indexer','indexertype',\%indexertypes);
# doing "LEFT OUTER JOIN wtindexers ON hits.browser REXP wtindexers.indexer" took 5 minutes, do this instead
&loadhash('wtpclasses', 'cfilename', 'cclass', \%pageclass);
&loadhash('wtwatch', 'wtwdom', 'wtwnote', \%watchlistdom);
&loadhash('wtwatch', 'wtwagt', 'wtwnote', \%watchlistbrw);

$entrypage = -1;
$exitpage = -1;
&initvisit();
$linebreak = '';
print "-- created by $me $version\n";
print "DROP TABLE IF EXISTS visits;\n";
print "CREATE TABLE visits(\n";
print " visitno INT PRIMARY KEY, -- visit number\n";
print " ninvisit INT, -- non-404 hits in this visit\n";
print " entrypage INT, -- index of first HTML page\n";
print " exitpage INT, -- index of last HTML page\n";
print " htmlinvisit INT, -- HTML hits in this visit*\n";
print " graphicsinvisit INT, -- graphic hits in this visit*\n";
print " bytesinvisit BIGINT, -- bytes in this visit*\n";
print " duration BIGINT, -- estimated duration in seconds, timespan*(nhits+1/nhits), 0? if 1 hit\n";
print " vdomain VARCHAR(255), -- copy of domain from hits*\n";
print " source VARCHAR(255), -- indexer, search, etc\n";
print " visitclass VARCHAR(255), -- class of objects referenced, from wtvclasses\n";
print " browsername VARCHAR(255), -- from hits.. (Mozilla 5.0 /MSIE 4.0/Opera etc)\n";
print " browsertype VARCHAR(255), --  (Moz/MSIE/Opera etc)\n";
print " platformtype VARCHAR(255), --  (PC/Mac etc)\n";
print " tld varchar(16), -- fkey (toplevel domain)\n";
print " ttld varchar(255), -- second level domain\n";
print " tttld varchar(255), -- third level domain\n";
print " city varchar(255), -- city from geoip\n";
print " authid varchar(255), -- username if the user authenticated, else blank\n";
print " watchop char(1), -- opcode for printvisitdetail if domain or browser matches\n";
print " watchnote varchar(255) -- note for printvisitdetail if domain or browser matches\n";
print ");\n";

@slices = ();			# init the slices list
$sqlrows = 0;			# global counter

@classort = ();
@main::tclasses = ();
@main::tclassct = ();

$oldvisit = -1;
# query the slice table
$hsq = "SELECT * FROM hitslices";
if (!($sliceh = $db->prepare($hsq))) {
    print "$me: cannot prepare $hsq ".$db->errstr . "\n";
    $logh->finish if $logh != 0;
    $db->disconnect;
    exit(0);
}
if (!$sliceh->execute) {
    print "$me: cannot execute $hsq ".$sth->errstr . "\n";
    $sliceh->finish;
    $logh->finish if $logh != 0;
    $db->disconnect;
    exit(0);
}
@hslab = @{$sliceh->{NAME}}; # get column names, namely sllo and slhi
while (@hsval = $sliceh->fetchrow_array) { # loop on slices
    for ($i=0; $i<@hslab; $i++) {
	$tablecol =  $hslab[$i];
	$v{$tablecol} = $hsval[$i];
	#print "bound $tablecol = $hsval[$i]\n"; 
    }
    $xq = &expandstring($q, \%v); # compute a new q, expanding the WHERE clause on vn to fill in sllo and slhi
    if (!($sth = $db->prepare($xq))) {
	print "$me: cannot prepare $xq ".$db->errstr . "\n";
	$sliceh->finish;
	$logh->finish if $logh != 0;
	$db->disconnect;
	exit(0);
    }
    if (!$sth->execute) {
	print "$me: cannot execute $xq ".$sth->errstr . "\n";
	$sth->finish;
	$sliceh->finish;
	$logh->finish if $logh != 0;
	$db->disconnect;
	exit(0);
    }
    @labels = @{$sth->{NAME}}; # get column names.
    @tables = @{$sth->{'mysql_table'}}; # .. and table names
    # for each returned row
    while (@array = $sth->fetchrow_array) {
	for ($i=0; $i<@labels; $i++) {
	    $tablecol = $tables[$i].'.'.$labels[$i]; # pay attention, this is subtle .. tables are "hits", "wtretcodes", "wtsuffixclass"
	    $v{$tablecol} = $array[$i];		     # bind the variables returned by $q (came from vq)
	    #print "bound $tablecol = $array[$i]\n";
	}
	&iter(); # do all the work for each hit
    } # while fetchrow
    $sth->finish;
} # loop on slices
&flush();
print ";\n";
$sth->finish;
$db->disconnect;
if ($oldvisit >= 0) { # if there were any visits at all
    # write out the slices table, a list of visit number ranges for the visits table
    print "\nDROP TABLE IF EXISTS visitslices;\n";
    print "CREATE TABLE visitslices(\n";
    print " slvlo INT, -- lowest visit number\n";
    print " slvhi INT  -- last visit number\n";
    print ");\n";
    print "INSERT INTO visitslices VALUES \n";
    $sep = '';
    $lo = 0;
    push @slices, $oldvisit; # put the last visit on the list
    foreach (@slices) {
	print "$sep($lo, $_)";
	$lo = $_ + 1;
	$sep = ",\n";
    }
    print ";\n";		  # there will be at least one slice
}
exit(0);

# ================================================================
# Called once for each hit.  Cause a visit record to be written when hits.vn changes.
#  &iter()
# hits may be recorded out of order by the web server
# ..so don't assume that the first hit in the log is the earliest one from the user
# ..take the first valid browser, etc
sub iter {
    my $indexerflag;
    my $tp;

    if ($v{'hits.vn'} ne $main::oldvisit) { # did the visit number advance
	&flush();		# this will call initvisit
	&assign_source_from_domain(); # for the new visit, see if domain shows it is an indexer
    }
    $main::oldvisit = $v{'hits.vn'};
    if ($v{'wtretcodes.good'} == 1) { # do not count 404s
	$main::ninvisit++;
	if ($v{'wtsuffixclass.sufclass'} eq 'html') {
	    $main::htmlinvisit++;
	    $main::entrypage = $v{'hits.sn'} if $main::entrypage == -1;
	    $main::exitpage  = $v{'hits.sn'};
	}
	$main::graphicsinvisit++ if $v{'wtsuffixclass.sufclass'} eq 'graphic';
	$main::bytesinvisit += $v{'hits.txsize'};
	$main::starttime = $v{'hits.systime'} if $main::starttime > $v{'hits.systime'}; # in case hits out of order
	$main::lasttime = $v{'hits.systime'} if $main::lasttime < $v{'hits.systime'};
	if ($main::browsername eq '') { # if we have not determined the browser
	    if ($v{'hits.browser'} ne '') { # if there is a browser in the log
		if (length($v{'hits.browser'}) > 255) { # too long a browsername causes SQL to crash
		    #warn "visitdata: truncated overlong browsername from $v{'hits.domain'}\n";
		    $v{'hits.browser'} = substr($v{'hits.browser'}, 0, 255);
		}
		($main::browsername, $indexerflag, $main::browsertype, $main::platformtype) 
		  = &detect_browser($v{'hits.browser'}, $v{'hits.domain'});
		$main::source = 'indexer' if $indexerflag eq 'indexer'; # some browsers are indexers
	    } # if there is a browser in the log
	} # if we have not determined the browser
	$main::authid = $v{'hits.authid'} if $v{'hits.authid'} ne ''; # whole session is auth if any pw given, take last seen
	&assign_source();	# check referrer and page to set $main::source
	&assign_visitclass() if $main::visitclass ne 'indexer';
    } # do not count 404s
} # iter

# ----------------------------------------------------------------
# Called when the visit number changes to write out a visit record.
sub flush {
    my ($word1, $secs, $mins);
    my $duration;
    &finish_source();
    $main::visitclass = &finish_visitclass();
    if ($main::ninvisit != 0) {	# a visit that is all 404s does not get flushed. beware.
	if ($main::sqlrows == 0) { 
	    print "INSERT INTO visits VALUES \n";
	    $main::linebreak = "";
	}
	($main::watchop, $main::watchnote) = &checkwatchlist($main::domain, $main::browsername); # look up the watch list
	$duration = $main::lasttime - $main::starttime; # a one hit session will have zero duration
	$duration = int((($main::ninvisit+1) * $duration)/$main::ninvisit);

	print $main::linebreak;
	$main::linebreak = ",\n";
	print "(";
	&writeval($main::visitno, ',');
	&writeval($main::ninvisit, ',');
	&writeval($main::entrypage, ',');
	&writeval($main::exitpage, ',');
	&writeval($main::htmlinvisit, ',');
	&writeval($main::graphicsinvisit, ',');
	&writeval($main::bytesinvisit, ',');
	&writeval($duration, ','); # estimated length of session in seconds
	&writeval($main::domain, ',');
	&writeval($main::source, ',');
	&writeval($main::visitclass, ',');
	&writeval($main::browsername, ',');
	&writeval($main::browsertype, ',');
	&writeval($main::platformtype, ',');
	&writeval($main::tld, ',');
	&writeval($main::ttld, ',');
	&writeval($main::tttld, ',');
	&writeval($main::city, ',');
	&writeval($main::authid, ',');
	&writeval($main::watchop, ',');
	&writeval($main::watchnote, '');
	print ")";
	# only add "sqlrowlimit" hits in each INSERT statement, so mysql does not give an error.
	if (++$main::sqlrows > $v{'sqlrowlimit'}) {
	    print ";\n";
	    push @slices, $main::visitno if $slices[-1] < $main::visitno; # record the last session number in each slice
	    # visits are not output in order but we want the slices to be in ascending order
	    $main::linebreak = '';
	    $main::sqlrows = 0;
	}
    }
    &initvisit();
} # flush

sub writeval {
    my $x = shift;
    my $sep = shift;
    print "'";
    print $x;
    print "'";
    print $sep;
}

# ================================================================
# called on the first hit in a visit
sub initvisit {
    @main::classort = ();
    @main::tclasses = ();
    @main::tclassct = ();
    %main::referrers_this_visit = ();
    $main::visitno = $v{'hits.vn'};
    $main::ninvisit = 0;
    $main::entrypage = -1;
    $main::exitpage = -1;
    $main::authid = '';
    $main::watchop = '';
    $main::watchnote = '';
    $main::htmlinvisit = 0;
    $main::graphicsinvisit = 0;
    $main::bytesinvisit = 0;
    $main::starttime = $v{'hits.systime'}; # for duration
    $main::lasttime = $v{'hits.systime'};
    if (length($v{'hits.domain'}) > 255) { # too long a domain would cause SQL to crash
	warn "visitdata: truncated overlong domain $v{'hits.domain'}\n";
	$v{'hits.domain'} = substr($v{'hits.domain'}, 0, 255);
    }
    $v{'hits.domain'} =~ s/\+/ /g; # for cities with space in the name
    $main::domain = $v{'hits.domain'};
    $main::source = '';
    $main::visitclass = '';
    $main::browsername = '';
    $main::browsertype = '';
    $main::platformtype = '';
    $main::city = '';
    $main::ttld = '';		# second and third level domain
    $main::tttld = '';
    # extract toplevel TLD .. prefer the country code from GeoIP if available
    $main::tld = $v{'hits.domain'};
    my $dom = $v{'hits.domain'};
    if ($main::tld =~ /^(.*)\[(.*?)\/(.*)\]$/) {
	$dom = $1;		# domain without the geoip
	$main::city = $3;	# super geoip, when available
	$main::tld = $2;	# result of geoip processing by logextractor
    } elsif ($main::tld =~ /^(.*)\[(.*)\]$/) {
	$dom = $1;		# domain without the geoip
	$main::tld = $2;	# result of geoip processing by logextractor
    } 
    if ($main::tld =~ /^\d+\.\d+\.\d+\.\d+$/) {
	$main::tld = "numeric";	# numeric IP, no geoip
	$dom = '';
    } elsif ($main::tld =~ /^[a-fA-F0-9:]+$/) {
	$main::tld = "numeric";	# IPV6, no geoip
	$dom = '';
    }
    if ($main::tld eq $v{'hits.domain'}) { # if no geodata
	$main::tld =~ s/^.*?:\/\/([^\/]+).*$/$1/; # remove https+://
	$dom = $main::tld;
	$main::tld =~ s/^.*\.([^.]+)$/$1/; # take everything after last dot
	$main::tld =~ tr/A-Z/a-z/; # downcase the TLD
    }
    if (length($main::tld) > 16) { # too long a TLD causes SQL to crash
	warn "visitdata: truncated overlong TLD $dom\n";
	$main::tld = substr($main::tld, 0, 16);
    }
    # compute second and third level names
    if ($dom =~ /^\d+\.\d+\.\d+\.\d+$/) {
	# numerics do not have ttld
    } elsif ($dom =~ /^[a-fA-F0-9:]+$/) {
	# IPV6 numerics do not have ttld
    } elsif ($dom eq '') {
	# numerics do not have ttld, even if they have geoip
    } else {
	if ($dom =~ /([^.]*\.[^.]*)$/) {
	    $main::ttld = $1;
	}
	if ($dom =~ /([^.]*\.[^.]*\.[^.]*)$/) {
	    $main::tttld = $1;
	}
    }
} # initvisit

# ================================================================
# descended from Webtrax version
# ($browser_name, $indexerflag, $browser_type, $platform_type) = &detect_browser($browserstring, $dom)
# uses global: @platforms, @browser_types

sub detect_browser {
    my $ua = shift;
    my $dom = shift;
    my $browser_name = $ua;
    $browser_name =~ s/<//g;	# nasty
    my $browser_type = 'other';
    my $platform_type = 'other';
    my $indexerf = '';
    my $tstring;
    my $i = 0;
    my $plat = $ua;
    $ua =~ s/^User-Agent: //;	# not helping anybody
    if ($ua =~ / WebTV\/(\S*?) /) {
	$browser_name = 'WebTV/' . $1;  # don't see this any more..

# indexers
    } elsif ($ua =~ /Googlebot-Mobile/) {
	# why does Googlebot use multiple browser IDs
	# DoCoMo/2.0 N905i(c100;TB;W24H16) (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html
	# SAMSUNG-SGH-E250/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 UP.Browser/6.2.3.3.c.1.101 (GUI) MMP/2.0 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)
	$browser_name = "Googlebot-Mobile";		# special case, Googlebot-Mobile
	$indexerf = 'indexer';
	$browser_type = 'indexer';
    } elsif ($ua =~ /\(compatible;.*(MSNBOT-MOBILE)/) {
	# T-Mobile Dash Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; Smartphone; 320x240; MSNBOT-MOBILE/1.1; +http://search.msn.com/msnbot.htm)
	$browser_name = "$1";		# special case, MSNBOT-MOBILE
	$indexerf = 'indexer';
	$browser_type = 'indexer';
    } elsif ($ua =~ /\(compatible; (Googlebot\/.*?);/) {
	# Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
	$browser_name = "$1";		# special case, Googlebot
	$indexerf = 'indexer';
	$browser_type = 'indexer';
    } elsif ($ua =~ /\(compatible; (Yahoo! Slurp);/) {
	# Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)
	$browser_name = "$1";		# special case, Slurp
	$indexerf = 'indexer';
	$browser_type = 'indexer';
    } elsif ($ua =~ /\((Slurp[^ ]*) .*\)/) {
	$browser_name = "$1";		# special case, Slurp
	$indexerf = 'indexer';
	$browser_type = 'indexer';
    } elsif ($ua =~ /^Yandex\/(.*?) /) {
	$browser_name = 'Yandex';
	$indexerf = 'indexer';
	$browser_type = 'indexer';
    } elsif ($ua =~ /\((Spinn3r .*?)\)/) {
	# Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2.1; aggregator:Tailrank (Spinn3r 2.3); http://spinn3r.com/robot) Gecko/20021130
	$browser_name = $1;
	$indexerf = 'indexer';
	$browser_type = 'indexer';

# phones
    } elsif ($ua =~ /Mobile Safari\/\S*$/) {
	$browser_name = $1;
	$browser_type = 'phone';
	$platform_type = 'phone';
    } elsif ($ua =~ /(Opera Mini\/.*?);/) {
	# Opera/9.60 (J2ME/MIDP; Opera Mini/4.2.13918/786; U; en) Presto/2.2.0
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(BlackBerry.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(MOT.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(SonyEricsson.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(Nokia.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(DoCoMo\/.*?) /) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(SAMSUNG.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(PHILLIPS.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /^(LG.*?)\//) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /(Windows CE)/) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /(PalmSource)/) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /(Symbian OS)/) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /(baidubrowser)/) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /(J2ME\/MIDP)/) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';
    } elsif ($ua =~ /(MAUI_WAP_Browser)/) {
	$browser_name = $1;
	$platform_type = 'phone';
	$browser_type = 'phone';

# browsers .. try to get version
# Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586
# Mozilla/5.0 (Windows Phone 10.0; Android GLOP; Mfr; GLOP) AppleWebKit/GLOP (KHTML, like Gecko) Chrome/GLOP Safari/GLOP Edge/GLOP.GLOP
# Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko
# Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; MAAU; rv:11.0) like Gecko
# Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0)
# Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0)
    } elsif ($ua =~ /(Edge\/\S*?)/) { # from https://msdn.microsoft.com/en-us/library/hh869301%28v=vs.85%29.aspx -- 20160102
	$browser_name = $1;		# Microsoft lies, says many other
    } elsif ($ua =~ /Trident\/7.0;.* rv:(\S*)\)/) { # MSIE 11.0 -- 20160102
	$browser_name = "MSIE $1";
    } elsif ($ua =~ /compatible; MSIE (\S*); Windows/) {# MSIE 9.0 and 10.0 -- 20160102
	$browser_name = "MSIE $1";
    } elsif ($ua =~ /^(Opera\/\S*)$/) {
	$browser_name = $1;
    } elsif ($ua =~ /^(Opera\/\S*?) /) {
	$browser_name = $1;
    } elsif ($ua =~ /^(iCab\/\S*?) /) { # from http://www.useragentstring.com
	$browser_name = $1;
	$platform_type = 'OSX';
    } elsif ($ua =~ /^Mozilla.*(Chrome\/\S*?) Safari/) { # from http://www.useragentstring.com/pages/Chrome/
	# Chrome says: Mozilla/5.0 (Windows NT 6.0; WOW64) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30
	$browser_name = $1;
    } elsif ($ua =~ /^Mozilla.*(Camino\/\S*)$/) { # from http://www.useragentstring.com
	$browser_name = $1;
	$platform_type = 'OSX';
    } elsif ($ua =~ /^(UBrowser\/[0-9.]*) /) { # UC Browser, Chrome derivative
	# Aviator|ChromePlus|coc_|Dragon|Edge|Flock|Iron|Kinza|Maxthon|MxNitro|Nichrome|OPR|Perk|Rockmelt|Seznam|Sleipnir|Spark|UBrowser|Vivaldi|WebExplorer|YaBrowser
	$browser_name = $1;
    } elsif ($ua =~ /^(Lynx\/.*?) /) {  # from http://www.useragentstring.com
	$browser_name = $1;
    } elsif ($ua =~ /^(Konqueror\/\S*)$/) {
	$browser_name = $1;
	$platform_type = 'Unix'; # Linux or FreeBSD
    } elsif ($ua =~ /^(Safari[0-9.]*) /) { # a lot of browsers say they are Safari when they are not really
	$browser_name = $1;
    } elsif ($ua =~ /^Mozilla.*(Safari\/\S*)$/) { # from developer.apple.com
	$browser_name = $1;

# misc
    } elsif ($ua =~ /(StarOffice\/\S*?);(\S*)$/) { # lies, says it's Mozilla
	$browser_name = $1;
	$platform_type = $2;	# Linux or FreeBSD
    } elsif ($ua =~ /\(compatible; GoogleToolbar .*?; (.*); MSIE (.*?)\)/) {
	# Mozilla/4.0 (compatible; GoogleToolbar 5.0.2124.6042; Windows XP 5.1; MSIE 7.0.5730.13)
	$browser_name = "MSIE $2";
	$plat = $1;
    } elsif ($ua =~ /\(compatible; (.*?); AOL .*?; (.*?); /) {
	# Mozilla/4.0 (compatible; MSIE 6.0; AOL 9.0; Windows NT 5.1; --garbage--)
	$browser_name = "$1; AOL $2";
	$plat = $2;
    } elsif ($ua =~ /\(compatible; (.*?); America Online Browser .*?; rev.*?; (.*?); /) {
	# Mozilla/4.0 (compatible; MSIE 6.0; America Online Browser 1.1; rev1.2; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322; Media Center PC 4.0)
	$browser_name = "$1; AOL $2";
	$plat = $2;
    } elsif ($ua =~ /\(compatible; (.*?); America Online Browser .*?; (.*?); /) {
	# Mozilla/4.0 (compatible; MSIE 6.0; America Online Browser 1.1; Windows NT 5.1; SV1; .NET CLR 1.1.4322)
	$browser_name = "$1; AOL $2";
	$plat = $2;
    } elsif ($ua =~ /\(compatible; (.*?); (.*?);/) {
	$browser_name = "$1";	# special case, Microsoft says Mozilla, platform,  lots of junk
    } elsif ($ua =~ /\(compatible; (.*?); (.*)\)/) {
	$browser_name = "$1";	# special case, Microsoft says Mozilla
    } elsif ($ua =~ /\(compatible; (.*)\)/) {
	$browser_name = "$1";		# special case, Microsoft
    } elsif ($ua =~ /^(Mozilla\/.*) \[.*?\] \((.*)\)$/) {
	$browser_name = "$1; $2";	# Mozilla for Windows
	$plat = $2;
    } elsif ($ua =~ /\((.*?); (U|I); .* (Firefox\/[0-9._]*)/) { # the U and I are the encryption strength
	# Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.7.10) Gecko/20050724 Firefox/1.0.6
	# Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1
	# Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1
	# Mozilla/5.0 (Windows; U; Win 9x 4.90; en-US; rv:1.8.0.7) Gecko/20060909 Firefox/1.5.0.7
	# Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.5) Gecko/2009011817 Gentoo Firefox/3.0.5
	$browser_name = "$3";
	$plat = $1; # generic platform
	$plat =~ s/Win 9x/Windows 9x/;

# other
    } elsif ($ua =~ /PLAYSTATION/) {
	$browser_name = 'PLAYSTATION';
    } elsif ($ua =~ /Google Desktop/) {
	$browser_name = 'Google Desktop';
    } else {
	#$browser_name =~ s/ .*$/ dft/; # trim browser after space
    }
    # de-crapify the browser name listed in the visit data
    $browser_name =~ s/\(.*?\).*$//g; # remarks in parentheses
    $browser_name =~ s/\[.*?\]//g; # remarks in brackets
    $browser_name =~ s/ \+?http:.*$//i; # help urls at end
    $browser_name =~ s/ Gecko\/\d+//i; # Gecko/number
    $browser_name =~ s/ CFNetwork\/[0-9.]+//i; # CFNetwork/number (Safari)
    $browser_name =~ s/ Darwin\/[0-9.]+//i; # Darwin/number (Safari)
    #$browser_name =~ s/ \(like Gecko\)//i; # refs to gecko
    #$browser_name =~ s/ \(like Gecko//i; # refs to gecko
    #$browser_name =~ s/ \(KHTML, like Gecko\)//i; # refs to gecko
    $browser_name =~ s/ AppleWebKit\/\d+//i; # AppleWebKit/number
    $browser_name =~ s/ KHTML\/\d+//i; # KHTML/number
    $browser_name =~ s/ Mach-O//i; # Mach-O
    $browser_name =~ s/ Java\/[0-9._]*//i; # Java and version
    $browser_name =~ s/\// /; # change slash to space
    $browser_name =~ s/ *$//; # trailing blanks
    #$browser_name =~ s/;//; # semicolon .. don't do this, breaks &amp;

# Mozilla/5.0 (iPod; U; CPU iPhone OS 4_2_1 like Mac OS X; pt-br) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5
# Mozilla/5.0 (iPad; U; CPU OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J3 Safari/6533.18.5
# Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5

# Mozilla/5.0 (Linux; U; Android 4.1.1; en-us; NB09 Build/JR003C.20130929) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30
# Mozilla/5.0 (Linux; Android 4.2.2; BLU DASH 4.0 Build/JDQ39) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.59 Mobile Safari/537.36
# Mozilla/5.0 (Android; Mobile; rv:26.0) Gecko/26.0 Firefox/26.0
# Opera/9.80 (Android; Opera Mini/7.5.33361/34.818; U; en) Presto/2.8.119 Version/11.10

# Mozilla/5.0 (Windows NT 10.0; GLOP) AppleWebKit/GLOP (KHTML, like Gecko) Chrome/GLOP Safari/GLOP Edge/GLOP.GLOP
# Mozilla/5.0 (Windows Phone 10.0; Android GLOP; Mfr; GLOP) AppleWebKit/GLOP (KHTML, like Gecko) Chrome/GLOP Safari/GLOP Edge/GLOP.GLOP
# Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
# Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0)
# Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)

    if (index($ua, 'Windows Phone') >= 0) {
	$browser_type = 'phone';
	$platform_type = 'WinPhone'; # also says Android, ignore that
    }
    if ($browser_type eq "phone") {
	if (index($ua, 'Android') >= 0) {
	    $platform_type = 'Android'; # Android sometimes says Linux
	}
    }

    if ($platform_type eq 'other') { # if platform_type not set yet
	if (index($ua, 'Android') >= 0) {
	    $browser_type = 'phone';
	    $platform_type = 'Android'; # Android sometimes says Linux
	} elsif (index($ua, 'Linux') >= 0) {
	    $platform_type = 'Linux';
	} elsif (index($ua, '(iPod') >= 0) { # order is important here
	    $platform_type = 'iPod';
	} elsif (index($ua, '(iPad') >= 0) {
	    $platform_type = 'iPad';
	} elsif (index($ua, '(iPhone') >= 0) {
	    $browser_type = 'phone';
	    $platform_type = 'iPhone';
	} elsif (index($ua, 'Mac OS X') >= 0) {
	    $platform_type = 'Mac';
	} elsif (index($ua, 'Darwin') >= 0) {
	    $platform_type = 'Mac';
	} elsif (index($ua, 'MacBook') >= 0) {
	    $platform_type = 'Mac';
	} elsif (index($ua, 'Mac_PowerPC') >= 0) {
	    $platform_type = 'Mac';
	} elsif (index($ua, 'Macmini') >= 0) {
	    $platform_type = 'Mac';
	} elsif (index($ua, 'iMac') >= 0) {
	    $platform_type = 'Mac';
	} elsif (index($ua, 'OS/2') >= 0) {
	    $platform_type = 'OS/2';
	} elsif (index($ua, 'FreeBSD') >= 0) {
	    $platform_type = 'Unix';
	} elsif (index($ua, 'SunOS') >= 0) {
	    $platform_type = 'Unix';
	} elsif (index($ua, 'IRIX') >= 0) {
	    $platform_type = 'Unix';
	} elsif (index($ua, 'X11') >= 0) {
	    $platform_type = 'Unix';
	}
    } # if platform_type not set yet

# See if this browser name is a web indexer, set $indexerf to 'indexer' if so.
    foreach (keys %main::indexertypes) { # from the "wtindexers" table
	$tstring = $_;
	$bns = lc $browser_name;
	if ($bns =~ /$tstring/i) { # check the regexp
	    $browser_type = $main::indexertypes{$tstring};
	    $indexerf = 'indexer' if $browser_type eq 'indexer';
	    last;
	}
    } # for

# Classify browsers into major groups.
    $browser_type = "Edge" if $browser_name =~ /^Edge/;
    $browser_type = "MSIE" if $browser_name =~ /^Trident/;
    $browser_type = "Mozilla" if $browser_name =~ /^Firefox/; 
    $browser_type = "Mozilla" if $browser_name =~ /^Camino/; 
    if ($browser_type eq 'other') {
	foreach (@main::browser_types) {
	    $tstring = $_;
	    if ($browser_name =~ /$tstring/i) {
		$browser_type = $tstring;
		last;
	    }
	} # for
    } # if $browser_type

# If matching against the whole UA didn't work, try matching $plat .. which is the full $ua or a platform name extracted from it
    if ($platform_type eq 'other') {
	foreach (@main::platforms) { # order sensitive
	    $tstring = $_;
	    if ($plat =~ /$tstring/i) {
		$platform_type = $tstring;
		$platform_type =~ s/Windows /Win/;
		last;
	    }
	} # for
    } # if $platform_type
    return ($browser_name, $indexerf, $browser_type, $platform_type);

} # detect_browser

# ================================================================
# On each hit, accumulate evidence of the visit's class from the page's class
# .. if the page has no declared class, look at the parent dir, back to the root
# .. if no class results use the name of the first dir below the root
# .. if no class results, use the class of the root (which should exist)
# Declared classes may be a list of terms, if the page could be part of several classes
# .. give them 1/n weight in the evidence.
# 
# reads: $main::source, $v{'hits.path'}, %pageclass
# wrties: $main::tclasses, $main::tclassct, $main::classort, $main::visitclass
sub assign_visitclass {
    my $t;

    if ($main::source eq 'indexer') { # if robotdomain said indexer
	$main::visitclass = 'indexer';
    } else {		# source is not indexer
	# does this page have a declared class
	my $tp = $v{'hits.path'}; # full path
	my $pc = $pageclass{$tp}; # if this page is specifically tagged
	if (($pc eq '') && ($tp !~ /\//)) { # if no slashes in path
	    $pc = 'junk';
	}
	if ($tp !~ /^\//) {	# if no beginning slash
	    $tp = '/' . $tp;	# put one in, or it will loop forever
	}
	if (($pc eq '') && ($tp =~ /^./)) { # if not tagged
	    $tp =~ s/\/[^\/]*$/\//; # remove filename
	    do {		    # scan prefixes
		$pc = $pageclass{$tp};
		$tp =~ s/\/[^\/]*\/$/\//; # remove one component
	    } until (($tp eq '/') || ($pc ne ''));
	}
	if ($pc eq '') { # if still no class
	    if ($v{'hits.path'} =~ /^(.+?)\//) {
		$pc = $1; # take first component of path
	    } else {
		$pc = $pageclass{'/'}; # take default .. ill formed path comes here
	    }
	}
	while ($pc =~ /^\/(.+)$/) {$pc = $1;} # if first cpt came out with a leading slash, get rid of it
	#print "--$v{'hits.path'}\n" if $pc eq '';
	# classify this hit
	if ($pc ne '') {
	    my @terms = split(/,/, $pc); # pageclass is comma separated list of terms
	    my $wt = 1/($#terms+1); # weight of a term is 1/n
	    foreach $t (@terms) {
		my $found = 0;
		my $i;
		for ($i=0; $i<=$#main::tclasses; $i++) {
		    # already seen this class for this visit
		    if ($t eq $main::tclasses[$i]) {
			$main::tclassct[$i] += $wt; # increase the weight
			$found++;
		    }
		} # for
		if ($found == 0) {
		    # new class for this visit
		    push @main::tclasses, $t;
		    push @main::tclassct, $wt;
		    push @main::classort, $#main::tclasses;
		}
	    } # foreach
	} # if $pc
    } # source is not indexer
} # assign_visitclass

# called at end of visit to possibly adjust visitclass
# ----- a session that hits more than N pages is a bulk transfer?
# ----- different handling if they load graphics or not?
# ----- a session with a lot of hits very fast (< 3 sec) is a bulk transfer? sometimes good sessions do this, caching obscures it too..
sub finish_visitclass {
    my $term;
    return "indexer" if $main::visitclass eq 'indexer';
    return '' if $#main::tclasses == -1; # never found any visitclass
    # sort tclasses and tclassct
    sub womp {$main::tclassct[$b] <=> $main::tclassct[$a]} # comparison routine
    my @x = sort womp @main::classort; # sort the class indices on the weight
    my $y = shift @x; # take the first index
    my $vc = $main::tclasses[$y]; # return the class with highest weight
    return $vc;
} # finish_visitclass

# ================================================================
# &assign_source_from_domain();
# called at the beginning of a visit to see if the domain is an indexer
sub assign_source_from_domain {
    foreach (@main::robotdomains) {
	if ($v{'hits.domain'} =~ /$_/i) { # these may begin with ^ in the data
	    $main::source = 'indexer';
	    last;
	}
    } # foreach
} # assign_source_from_domain

# ================================================================
# &assign_source();
# called on each hit to figure out the classification of the hit source
# .. possible results: indexer, refspam, search, search+hp, link, link+hp
# .. this is not perfect: the +hp designations depend on what we saw last.
# ..  does +hp always trump?
sub assign_source {
    return if $main::source eq 'indexer' || $main::source eq 'refspam'; # trapping states
    my $headpage = 0;
    if ($v{'hits.filename'} eq 'robots.txt') {
	$main::source = 'indexer';	# any session that touches robots.txt is an indexer
    } elsif ($v{'hits.filename'} eq 'knagnord.shtml') {
	$main::source = 'indexer';	# any session that touches this file is a misbehaving indexer
    } elsif ($v{'hits.filename'} eq 'rewortak.html') {
	$main::source = 'indexer';	# any session that touches this file is a misbehaving indexer
    } elsif (($v{'hits.browser'} ne '') && ($v{'hits.browser'} eq $v{'hits.referrerurl'})) {
	$main::source = 'refspam';	# hits with user_agent == referrerurl are usually crap	    
    } elsif ($v{'hits.referrerurl'} eq 'refspam') {
	$main::source = 'refspam';	# prereferrer transform can set this	    
    } else {
	foreach (@main::headpages) {
	    if ($v{'hits.filename'} =~ /^$_/i) { # about-multics.html ne multics.html
		$headpage = 1;
		last;
	    }
	} # foreach
	my $localrefer = 0;
	foreach (@main::localdomregex) {
	    if ($v{'hits.referrerurl'} =~ /$_/i) { # these may begin with ^ in the data
		$localrefer = 1;
		last;
	    }
	} # foreach
	if ($localrefer == 1) {
	    # local referrer, don't reset source of visit, probably internal
	} elsif ($v{'hits.referrerquery'} ne '') { # if had a query, is a search
	    if ($headpage == 1) {
		$main::source = 'search+hp' if $main::source eq '' || $main::source eq 'search';
	    } else {
		$main::source = 'search' if $main::source eq '';
	    }
	} elsif ($v{'hits.referrerurl'} eq '') {
	    # blank referrer, can't infer anything
	} else {			# regular link
	    $main::referrers_this_visit{$v{'hits.referrerurl'}}++; # count the nonlocal referrers for this visit, see below
	    # -- temp hack to silence refspam from russians etc, kills a few good refs but so what
	    # .. should make this list of TLDs variable
	    if ($main::domain =~ /\[(..)/) { # if have a geoloc country code .. kill refs to "getporno.xyz" etc
		my $cc = $1;
		if (($cc eq 'ua') || ($cc eq 'ru') || ($cc eq 'by') || ($main::tld eq 'ua') || ($main::tld eq 'ru') || ($main::tld eq 'by')) {
		    $main::source = 'refspam';
		}
	    } elsif ($main::domain =~ /\.(..)$/) { # no geoloc but have two letter domain
		my $cc = $1;
		if (($cc eq 'ua') || ($cc eq 'ru') || ($cc eq 'by')) {
		    $main::source = 'refspam';
		}
	    } elsif ($main::domain =~ /example\.com\[nl/) { # asshole in the netherlands
		$main::source = 'refspam';
	    }
	    if ($headpage == 1) {
		$main::source = 'link+hp' if $main::source eq '' || $main::source eq 'link';
	    } else {
		$main::source = 'link' if $main::source eq '';
	    }
	} # regular link
    }
} # assign_source

# called at end of visit to possibly adjust source
# -- issue: if a visit has all local refs, it will have no source, is this OK?
sub finish_source {
    my $x = scalar keys(%main::referrers_this_visit); # get count of different nolocal referrers
    #print "-- $main::domain $x\n";
    if ($x > $main::refspamthresh) { # referrer spam if >> different links in visit
	$main::source = 'refspam';
    }
    # elsif ((only one hit) && (ref not match wtlocalreferrerregexp) && (hit on listed CGI)) {
    #	$main::source = 'refspam';
    # }
# ----- repeated loads of the same page or few pages is some kind of asshole, but not necessarily spam.
} # finish_source
# ================================================================
# Load one column of given SQL table into a list and return it
# &loadtable($tablename, $colname);
sub loadtable {
    my $tablename = shift;
    my $colname = shift;
    my @temp;
    my $sth;
    if (!($sth = $db->prepare("SELECT * FROM $tablename"))) {
	die "$me: cannot prepare $tablename query ".$db->errstr;
    }
    if (!$sth->execute) {
	die "$me: cannot execute $tablename query ".$sth->errstr;
    }
    @labels = @{$sth->{NAME}};
    for ($i=0; $i<@labels; $i++) {
	last if $labels[$i] eq $colname;
    } # for
    die "$me: column $colname not found in $tablename" if $i >= @labels;
    while (@array = $sth->fetchrow_array) {
	push @temp, $array[$i];
    }
    $sth->finish;
    return @temp;
} # loadtable
#
# ================================================================
# ($opcode, $annotation) = &checkwatchlist($main::domain, $main::browsername);
sub checkwatchlist {
    my $dom = shift;
    my $brw = shift;
    my $val = '';
    my $opc = '';
    #$val = $watchlistdom{$dom};
    foreach (keys %main::watchlistdom) { # from the "wtwatch" table
	$tstring = $_;
	if ($dom =~ /$tstring/i) { # check the regexp
	    $val = $main::watchlistdom{$tstring};
	    last;
	}
    } # for
    #$val = $watchlistbrw{$brw} if $val eq '';
    if ($val eq '') {
	foreach (keys %main::watchlistbrw) { # from the "wtwatch" table
	    $tstring = $_;
	    if ($brw =~ /$tstring/i) { # check the regexp
		$val = $main::watchlistbrw{$tstring};
		last;
	    }
	} # for
    }
    $opc = substr($val,0,1) if $val ne '';
    $val = substr($val,1) if $val ne '';
    return ($opc, $val);
} # checkwatchlist
# ================================================================
# load two columns of SQL table into a local hash
# @list = &loadhash($tablename, $col1name, $col2name, \%hash);
# then reference $hash{$col1} to get $col2
sub loadhash {
    my $tablename = shift;
    my $col1name = shift;
    my $col2name = shift;
    my $vp = shift;
    my @temp;
    my $sth;
    if (!($sth = $db->prepare("SELECT * FROM $tablename"))) {
	die "$me: cannot prepare $tablename query ".$db->errstr;
    }
    if (!$sth->execute) {
	die "$me: cannot execute $tablename query ".$sth->errstr;
    }
    @labels = @{$sth->{NAME}};
    my $i1 = -1;
    my $i2 = -1;
    for ($i=0; $i<@labels; $i++) {
	$i1 = $i if $labels[$i] eq $col1name;
	$i2 = $i if $labels[$i] eq $col2name;
    } # for
    die "$me: column $col1name not found in $tablename" if $i1 == -1;
    die "$me: column $col2name not found in $tablename" if $i2 == -1;
    while (@array = $sth->fetchrow_array) {
	$$vp{$array[$i1]} = $array[$i2] if $array[$i1] ne '';
    }
    $sth->finish;

} # loadhash

# ================================================================
# load config file
# $s = &loadfile ($arg, \%values)
sub loadfile {
    my $arg = shift;
    my $vp = shift;
    my $c = '';
    my $olddelim = $/;
    $/ = undef;
    if (open(TPT, "$arg")) {
	$c = <TPT>;		# read whole file
	close(TPT);
    } else {
	die "$$vp{'me'}: $arg missing $!\n";
    } # if open
    $c = &expandblocks($c, $vp, 0); # expands blocks in the tpt but does not process includes
    $/ = $olddelim;
    return $c;
} #loadfile

# end
