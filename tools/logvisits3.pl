#!/usr/local/bin/perl
#
# Copyright 2006-2015, Tom Van Vleck
#
# Web Log analysis that finds "visits" by the same domain
#
# Reads an NCSA [combined] web server log and writes 
# a smilar log file prefixed by two additional fields: visit number and sequence within visit.
# Assumes that the log is already sorted in date order.
# .. webtrax usesthis program to create "log2db.sql"
#
# Original idea of visits from John Callender's 1996 "webtrax"
#
# in -sql mode, writes out schema and then INSERT VALUES statements to load.
#
# logvisits [-v] [-sql] [-e configfile] filepath ... > outpath
#
# security reasoning:
# The Apache log comes through here. readapacheline.pm does not escape anything.
# sqlfmt() also ampersand-escapes ampersand, less-than, greater-than, double quote.
# cleanstring() is applied to browser, domain, path, referrer.  It undoes percent-escapes.
# SQL injection is addressed by percent-escaping single quote in cleanstring().
#
# 04/11/06 THVV 1.0 From logextractor
# 04/30/06 THVV 1.1 Query is per-hit
# 05/08/06 THVV 1.2 add transforms and extractquery (slows it way down, maybe they should be separate)
# 05/10/06 THVV 1.3 add slices table
# 06/08/06 THVV 1.4 improve cleanstring: double percent decode, drop double quote, percent escape single quote
# 06/08/06 THVV 1.4 introduced cache in "transform()" - saved 1200 transforms but no difference in runtime
# 06/09/06 THVV 1.5 add index.html before path transform; add -visitsecs
# 06/22/06 THVV 1.6 get configuration from -e arg and SQL
# 12/26/06 THVV 1.7 add path to output sql, do domain mapping before visit detection
# 12/28/06 THVV 1.71 deal correctly with a few hits that have a URL in the GET instead of a file name
# 02/08/07 THVV 1.72 add -config
# 05/03/07 THVV 1.721 handle cities with space in the name
# 11/13/07 THVV 1.722 fix bug if there are exactly rowlimit hits
# 12/27/07 THVV 1.8 add authid
# 04/03/08 THVV 1.81 kill referrer spam in filename query term
# 07/04/08 THVV 1.82 compress multiple slashes in pathname into one
# 02/04/09 THVV 1.83 do 500 hits per slice instead of 1000
# 08/09/10 THVV 1.831 sanitize myquery
# 05/24/11 THVV 1.84 fix normalization of .. in file paths
# 09/09/11 THVV 1.85 handle google queries with # instead of ?, and cleanstring the query
# 06/01/14 THVV 1.86 MySQL 5.6 is stopping rathar than truncating if a field is too long .. add SET SESSION sql_mode=''
# 08/21/15 THVV 1.87 blank out garbagy yandex and yahoo queries, recognize a few more query introducers
# 08/24/15 THVV 1.871 handle missing query
# 04/10/16 THVV 1.872 percent-decode the path before processing, so that percent-encoded ? will be acted upon
# 01/15/18 THVV 1.873 in "transform", be case insensitive
# 09/15/20 THVV 2.0 expandfile3
# 04/06/21 THVV 2.01 change /./ to / in path
# 06/11/21 THVV 2.02 expandfile3 => expandfile

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

use readapacheline;
use expandfile;
use Time::Local;
use DBI;

$v{'visitlimit'} = 1800; # length in seconds of idle time before visit expires
$v{'sqlrowlimit'} = 500; # add this number of rows at a time to avoid SQL error .. 1000 led to out of memory errors at Pair.
$v{'version'} = '2.02';
$v{'me'} ='logvisits3';
$me ='logvisits';

my %lasttime;
my %sequence;
my %visitno;

$visitcounter = 0;
$sep = '';
$sqlrows = 0;

$monno{'Jan'} = 0;
$monno{'Feb'} = 1;
$monno{'Mar'} = 2;
$monno{'Apr'} = 3;
$monno{'May'} = 4;
$monno{'Jun'} = 5;
$monno{'Jul'} = 6;
$monno{'Aug'} = 7;
$monno{'Sep'} = 8;
$monno{'Oct'} = 9;
$monno{'Nov'} = 10;
$monno{'Dec'} = 11;

if ($#ARGV < 0) {
    die "$me: too few arguments";
}

@slices = ();			# init the slices list

my $transforms_done = 0;
my $verbose = 0;
my $sqlmode = 0;
while ($#ARGV >= 0) {
    $arg = shift;
    if ($arg eq "-v") {
	$verbose = 1;
    } elsif (($arg eq "-config") || ($arg eq "-e")) {
	$configName = shift;
	my $config = &loadfile($configName, \%v);
	$v{'_xf_currentfilename'} = $configName;
	my $junk = &expandstring($config, \%v); # config file is a template, expand it
	die "$me: $configName did not set _xf_hostname" if $v{'_xf_hostname'} eq '';
	# Open the database
 	if (!($db = DBI->connect("DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}", $v{'_xf_username'}, $v{'_xf_password'}))) {
 	    print "$me: cannot open DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}, $v{'_xf_username'}\n";
 	    exit(0);
 	}
	@domtranslist = &loadtable($db, 'wtpredomain', 'predomain');
	@pathtranslist = &loadtable($db, 'wtprepath', 'prepath');
	@refertranslist = &loadtable($db, 'wtprereferrer', 'prereferrer');
	$db->disconnect;
    } elsif ($arg eq "-sql") {
	$sqlmode = 1;
	print "-- $me $v{'version'}\n";
	print "SET SESSION sql_mode='';\n";
	print "DROP TABLE IF EXISTS hits;\n";
	print "CREATE TABLE hits(\n";
	print " vn INT, -- visit number\n";
	print " sn INT, -- sn\n";
	print " domain VARCHAR(255), -- dom\n";
	print " accessdir VARCHAR(255), -- accessdir, not used\n";
	print " authid VARCHAR(255), -- userid if the user authenticated, else blank\n";
	print " systime BIGINT, -- Unix time stamp for the hit\n";
	print "  verb VARCHAR(255), -- from command: GET/HEAD/etc \n";
	print "   myquery VARCHAR(511), -- from path in command\n";
	print "   path VARCHAR(511), -- from path in command\n";
	print "   dir VARCHAR(511), -- from path in command\n"; # --------------- obsolete
	print "   filename VARCHAR(511), -- from path in command\n";
	print "   filetype VARCHAR(511), -- from path in command\n";
	print "  protocol VARCHAR(255), -- from command, e.g. HTTP 1.1\n";
	print " retcode CHAR(3), -- server return code\n";
	print " txsize BIGINT, -- size in bytes\n";
	print "  referrerurl VARCHAR(511), -- extracted from referrer\n";
	print "  referrerquery VARCHAR(511), -- extracted from referrer\n";
	print " browser VARCHAR(511) -- browser\n";
	print ");\n";
    } else {
	&process_one_file($arg, $verbose, $sqlmode);
    }
} # while

if ($sqlmode == 1) {
    print ";\n";
    # write out the slices table, a list of visit number ranges
    # .. used by printvisitdetail to break up the hits into smaller groups, avoid blowing out memory
    print "\nDROP TABLE IF EXISTS hitslices;\n";
    print "CREATE TABLE hitslices(\n";
    print " sllo INT, -- lowest visit number\n";
    print " slhi INT  -- last visit number\n";
    print ");\n";
    print "INSERT INTO hitslices VALUES \n";
    $sep = '';
    $lo = 0;
    push @slices, $visitcounter; # put the last visit on the list
    foreach (@slices) {
	print "$sep($lo, $_)";
	$lo = $_ + 1;
	$sep = ",\n";
    }
    print ";\n";		# there will be at least one slice
    print "-- transforms: $transforms_done\n"; # print stats
}
exit(0);

#----------------------------------------------------------------
# Process one log file

sub process_one_file {
    my $the_log_file = shift;
    my $verbose = shift;
    my $sqlmode = shift;

    my $oldsystime = 0;
    my $s;

    if ($the_log_file =~ /\.gz$|\.z$/i) {
	my $catter = "";
	my $zcok = `which zcat`;
	my $gzcok = `which gzcat`;
	$catter = "zcat" if $zcok ne "";
	$catter = "gzcat" if $gzcok ne "";
	die "error: neither zcat or gzcat found, cannot open $filename[$i]" if $catter eq "";
	open(LOG, "$catter $the_log_file |") or die "$me: $the_log_file missing. $!";
    } else {
	open(LOG, "$the_log_file") or die "$me: $the_log_file missing. $!";
    }
    $v{'_currentfilename'} = $the_log_file;

    while(<LOG>) { # scan the file
	chop;
        $line = $_;
	next if &readApacheLine($line, $verbose, \%v) == 1;
	#next if int($v{'size'}) == 0 && $v{'retcode'} eq '200' && $v{'verb'} eq 'GET';

# Convert the date to systime
	$systime = &apacheTimeToSystime($v{'accesstime'});
	if ($systime == 0) {
	    print "$main::me: cannot parse $v{'accesstime'}\n" if $verbose;
	    next;		# end processing of record
	}

# SQL Mode derives a bunch of items from the raw log data
	if ($sqlmode == 1) {
	    $v{'domain'} =~ s/\+/ /g; # for cities with space in the name
	    # trim any CGI args or queries to my software off the path
	    ## percent-decode the path here so question and hash can be percent encoded
	    ## $v{'path'} =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/eg;
	    $v{'path'} = &cleanstring($v{'path'});
	    if ($v{'path'} =~ /^(.*?)\?(.*)$/) { # if it contains a question mark, then there was a query sent to me
		$v{'path'} = $1;
		$v{'myquery'} = $2;
		$v{'myquery'} = &extractquery($v{'path'}, $v{'myquery'});
		$v{'myquery'} = '(refspam)' if $v{'myquery'} =~ /^http/; # kill referrer spammers.. this should be optional
	    } else {
		$v{'myquery'} = '';
	    }
	    if ($v{'path'} =~ /^https?:\/\/.*?(\/.*)$/) { # this is a URL not a filename, adjust
		$v{'path'} = $1;
	    } elsif ($v{'path'} =~ /^https?:\/\/.*?\/$/) { # this is a URL not a filename, adjust
		$v{'path'} = '/index.html';
	    }
	    if ($v{'path'} =~ /^(.*?)#(.*)$/) { # browser should not send hash term in filename, defective crawlers do this, will 404
		$v{'path'} = $1;
	    }

	    $v{'path'} =~ s/\/\/+/\//g; # compress multiple slashes into one, defective crawlers do this
	    $v{'path'} .= 'index.html' if $v{'path'} =~ /\/$/; # if ends in slash, add ".index.html" -- do this before transforms

	    while ($v{'path'} =~ /\/[^.\/][^\/]*?\/\.\.\//) { # transform /word/../foo => /foo repeatedly.
		$v{'path'} =~ s/\/[^.\/][^\/]*?\/\.\.\//\//; # this is not quite right, a path like /foo/.a/../bar will not become /foo/bar
	    }
	    while ($v{'path'} =~ /^\/\.\./) { # remove leading /..
		$v{'path'} =~ s/^\/\.\./\//;
	    }
	    $v{'path'} =~ s/\/\.\//\//; # change /./ to /

	    # apply transformations. These are WAY slow.  21 sec -> 172 sec.  Got it down to 42 sec, course it didn't work
            &transform('domain', @domtranslist);
            &transform('path', @pathtranslist);
            &transform('referrer', @refertranslist);

	    # changes to path may have altered dir/filename split or filetype
	    if ($v{'path'} =~ /^(.*\/)(.*)$/) {
		$v{'dir'} = $1;	# take beginning up to last slash ------------ obsolete
		$v{'filename'} = $2;
	    } else {
		$v{'dir'} = '/';	# no slash in name, ugh ------------ obsolete
		$v{'filename'} = $v{'path'};
	    }
	    if ($v{'path'} =~ /^.*\.(.*)$/) { # filetype is after the last dot
		$v{'filetype'} = $1;
	    } else {
		$v{'filetype'} = ''; # no dot, no filetype
	    }
	    # changes to referrer may make extractquery's job easier
	    my $tempref = &cleanstring($v{'referrer'}); # allows the ? and # to be percent encoded, cleans out traps
	    $v{'referrerurl'} = $tempref;
	    $v{'referrerquery'} = '';
	    if ($tempref =~ /^(.*?:\/\/.*?)\?(.*)$/) { # non-greedy match, find first question mark
		$v{'referrerurl'} = $1;		       # change whole URL to drop the question mark part
		$v{'referrerquery'} = $2;	       # extract the query
	    } elsif ($tempref =~ /\/\#.*q=/) { # Google also accepts queries with a hash, treat it as a query if it has q=
		if ($tempref =~ /^(.*?:\/\/.*?)\#(.*)$/) { # non-greedy match, find first sharp
		    $v{'referrerurl'} = $1;		   # change whole URL to drop the hash part
		    $v{'referrerquery'} = $2;              # extract the query
		}
	    } else {
		# no referrer query .. see if it is a garbagy Yahoo referrer
		if ($tempref =~ /http:\/\/r.search\.yahoo\.com\/_.*/) {
		    # http://r.search.yahoo.com/_ylt=(garbage);_ylu=(garbage)
		    $v{'referrerurl'} = 'search.yahoo.com/(encoded)'; # worthless and ugly Yahoo query, just blank it
		}
	    }
	    # normalize the referrer URL
	    if ($v{'referrerurl'} ne '') {
		if ($v{'referrerurl'} =~ /^.*\@(.*)$/) {
		    $v{'referrerurl'} = $1;	# Strip off username and password.
		}
		$v{'referrerurl'} =~ s/:80\//\//; # Remove port 80 if shown explicitly.
		$v{'referrerurl'} =~ s/\.\//\//; # Change ./ to / ---------- should I use "g" here
		$v{'referrerurl'} =~ s/\++/+/g; # Compress strings of pluses.
	    }
	    # normalize the referrer query
	    if ($v{'referrerquery'} ne '') {
		$v{'referrerquery'} =~ s/ +/ /g; # Compress strings of blanks.
		$v{'referrerquery'} =~ s/\++/+/g; # Compress strings of pluses.
		$v{'referrerquery'} =~ s/ $//; # remove trailing blank
		$v{'referrerquery'} =~ s/\.+$//; # remove trailing dots
	    }
	    # extract the query from the field, eliminating lots of crap
	    $v{'referrerquery'} = &extractquery($v{'referrerurl'}, $v{'referrerquery'});
	    # clean up the browser
	    $v{'browser'} = &cleanstring($v{'browser'});
	} # if sqlmode

# Expire domains if they have gone silent
	foreach (keys %main::visitno) {
	    if (($systime - $main::lasttime{$_}) > $v{'visitlimit'}) {
		delete $main::lasttime{$_};
		delete $main::sequence{$_};
		delete $main::visitno{$_};
	    }
	} # foreach

# See if there is a visit open for this domain.
	my $dom = $v{'domain'};
	if (defined($main::visitno{$dom})) {
	    # have a visit open
	    $main::sequence{$dom}++;
	} else {
	    # open a new visit
	    $main::visitno{$dom} = ++$main::visitcounter;
	    $main::sequence{$dom} = 0;
	}
	$main::lasttime{$dom} = $systime;
	my $vn = $main::visitno{$dom};
	my $sn = $main::sequence{$dom};

# Write out a record per hit
	if ($sqlmode == 1) {
	    if ($main::sqlrows == 0) {
		print "INSERT INTO hits VALUES \n";
		$main::sep = "";
	    }
	    # --- these must match exactly the schema above in type and order
	    $s = "$main::sep($vn,$sn"; # separator, open paren, visitno, sequenceno
	    $s .= &sqlfmt($v{'domain'});      # sanitized with cleanstring()
	    $s .= &sqlfmt($v{'accesseddir'}); # set by readapacheline.pm, not used
	    $s .= &sqlfmt($v{'authid'});      # set by readapacheline.pm
	    $s .= ",$systime";
	    $s .= &sqlfmt($v{'verb'});        # set by readapacheline.pm
	    $s .= &sqlfmt($v{'myquery'});     # extracted from path, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'path'});        # set by readapacheline.pm, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'dir'});         # --------------- obsolete, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'filename'});    # --------------- obsolete, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'filetype'});    # extracted from path, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'protocol'});    # set by readapacheline.pm, must begin HTTP
	    $s .= &sqlfmt($v{'retcode'});     # set by readapacheline.pm, must be all numeric
	    $s .= &sqlfmt($v{'size'});        # set by readapacheline.pm, must be all numeric
	    $s .= &sqlfmt($v{'referrerurl'}); # extracted from referrer, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'referrerquery'}); # extracted from referrer, sanitized with cleanstring()
	    $s .= &sqlfmt($v{'browser'});     # sanitized with cleanstring()
	    $s .= ")";
	    $main::sep = ",\n";
	    # only add "sqlrowlimit" hits in each INSERT statement, so mysql does not give an error.
	    if (++$main::sqlrows > $v{'sqlrowlimit'}) {
		$s .= ";\n";
		push @slices, $vn if $slices[-1] < $vn; # record the last session number in each slice
		# visits are not output in order but we want the slices to be in ascending order
		$main::sqlrows = 0;
	    }
	} else {
	    # non SQL mode, just output the same as the input with VN and SN on the front, could then sort
	    my $vn = &numfmt($vn, 8);
	    my $sn = &numfmt($sn, 8);
	    $s = "$vn $sn $v{'domain'} $v{'accesseddir'} $v{'authid'} \[$v{'accesstime'}\] \"$v{'command'}\" $v{'retcode'} $v{'size'} \"$v{'referrer'}\" \"$v{'browser'}\"\n";
	}
	print "$s";

    } # while <LOG>
    close LOG;

} # process_one_file

# ================================================================
# convert 10/Apr/2006:00:01 -0400 to a big number of seconds
sub apacheTimeToSystime {
    my $arg = shift;
    if ($arg =~ /^(.+?)\/(.+?)\/(.+?):(\d\d):(\d\d):(\d\d) (.*)$/) {
	my $dd = $1;
	my $mmm = $2;	# 3 letter abbr
	return 0 if !defined($main::monno{$mmm});
	my $yyyy = $3;
	my $hh = $4;
	my $mm = $5;
	my $ss = $6;
	my $tzo = $7;
	if ($tzo =~/z/i) {
	    $tzo = 0;	# zulu
	} elsif ($tzo =~ /-(\d\d)(\d\d)/) {
	    $tzo = (60 * $2) + (60 * 60 * $1); # EDT is -0400
	} elsif ($tzo =~ /\+(\d\d)(\d\d)/) {
	    $tzo = -(60 * $2) - (60 * 60 * $1);
	} else {
	    $tzo = 0;	# bad offset
	}
	return timegm($ss, $mm ,$hh, $dd, $main::monno{$mmm}, $yyyy) + $tzo;
    } else {
	return 0;
    }
} # apacheTimeToSystime

# ================================================================
# $val = &numfmt ($number, $width)
sub numfmt { # returns number right justified, zerofilled
	my $x = shift;
	my $y = shift;
	my $z = "00000000000000$x";
use strict;    

	return substr ($z, -$y, $y);
} # numfmt

# ================================================================
# $val = &sqlfmt ($fld)
sub sqlfmt { # returns field formatted for sql
    my $x = shift;
    $x = '' if $x eq '-';	# Get rid of this now.
    $x =~ s/'/./g;		# no SQL injection
    $x =~ s/\\/./g;		# no SQL fuckup
    $x =~ s/&/\&amp;/g;		# chars that screw up HTML
    $x =~ s/</\&lt;/g;
    $x =~ s/>/\&gt;/g;
    $x =~ s/"/\&quot;/g;
    return ",'" . $x . "'";
} # sqlfmt

# ================================================================
# given a query string, return the query portion
# $query = &extractquery($path, $query)
# if the query is encoded, just return "(encoded)"
sub extractquery {
    my $newpath = shift;
    my $newquery = shift;
    # cache:tKH72GRyxgwJ:www.multicians.org/thvv/photoshop.html prepare images for web
    if ($newquery =~ /^cache:............:.*? (.*)$/i) {
	$newquery = $1;
    } elsif ($newquery =~ /from=yandex.ru.*/) {
	# query is from=yandex.ru%3Bsearch%3Bweb%3B%3B&text=&etext=(garbage)&uuid=&state=(garbage)&sign=(garbage)&keyno=0&l10n=ru&cts=1440050182494&mc=6.05322325383
	$newquery = '(encoded)'; # worthless and ugly Yandex query
    } elsif (($newpath eq "http://www.baidu.com/link") && ($newquery =~ /url=.*/)) {
	# referrer was http://www.baidu.com/link?url=(garbage)&wd=&eqid=bd1a4c45000086b40000000255d6e7b7
	$newquery = '(encoded)'; # worthless and ugly baidu query
    } else {
	my $x1 = '&' . $newquery . '&';
	$x1 =~ s/\?/\&/g;
	$x1 =~ s/&and=|&ask=|&as_q=|&as_epq=|&aw=|&aw0=|&cat=|&fi_1=|&findrequest=|&general=|&ht=|&key=|&keyword=|&keywords=|&kw=|&metatopic=|&mfkw=|&mt=|&oldquery=|&p=|&parole=|&qkw=|&qr=|&qry=|&qs=|&qt=|&query=|&querystring=|&queryterm=|&question=|&r=|&realname=|&request=|&s=|&search=|&search_term=|&searchfor=|&searchstring=|&searchtext=|&searchwd=|&sid=|&ss=|&subid=|&terms=|&text=|&u=|&value=|&wd=/\&q=/gi;
	if ($x1 =~ /&q=([^&][^&][^&]+)&/) { # if it is at least 3 chars
	    $newquery = $1;
	} elsif ($x1 =~ /&q=&/) { # empty query
	    $newquery = '(encoded)';
	}
    }
    $newquery =~ s/\+/ /g;
    $newquery =~ s/ +/ /g;
    if ($newquery =~ /^"(.*)"$/) {
	$newquery = $1;		# unwrap quotes
    }
    return $newquery;
} # extractquery

# ================================================================
# transform path, domain, or referrer
# &transform($var, @transformlist)
# - transformlist is a list of substitute commands
# - each command is s~regexp~value~[i]
# -- BUG: does not work in perl 5.8.9 (2009) which is installed at Pair
sub transform {
    my $arg1 = shift; # 'domain'
    my $key = $v{$arg1};
    if (defined($cache{$key})) { # if we are transforming the same string, get same result
	$v{$arg1} = $cache{$key};
	return;
    }
    $v{$arg1} = &cleanstring($key);
    while ($cmd = shift) {
	my $x = $v{$arg1};
	if ($cmd =~ /^s~(.*)~(.*)~/) {
	    my $lhs = $1;
	    #warn "testing $lhs $x\n" if ($lhs =~ /c-73-215-248-73/);
	    # my $rhs = $2;
	    if ($x =~ m|$lhs|i) { # be case insensitive
	        #warn "found $arg1 $lhs\n";
		eval "\$x =~ $cmd";
		$cache{$key} = $x; # assumes that domain, path, and referrer can all be cached together 
		$v{$arg1} = $x;
		$transforms_done++;
		last;		# quit after the first one that works
	    }
	}
    } # while
} # transform

# ================================================================
# change illegal characters to dot for browser, path, domain, and referrer
# $x = &cleanstring($s)
# .. since this removes brackets, there is no chance of %[]% attacks
sub cleanstring {
    my $x = shift;
    $x =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/eg; # Percent-decode
    $x =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/eg; # .. do it twice, some image searches double encode
    $x =~ s/"//g;		# Remove double quote.
    $x =~ s/'/%27/g;		# Introduce percent escape for single quote, because it is going into SQL.
    $x =~ tr/[0-9][A-Z][a-z]\?\.,:%;\-\(\)\&\/_+=*^%$\\|\#\~@!{}\[\] /./c; # remove bad chrs.. single quote, dbl quote, lt, gt, low, high, brackets
    #$x =~ s/\n//g;		# Remove newline characters.
    #$x =~ s/\r//g;		# Remove return characters.
    #$x =~ s/\000//g;		# Remove NUL characters.
    return $x;
} #cleanstring
# ================================================================
# @list = &loadtable($db, $tablename, $colname);
sub loadtable {
    my $dbh = shift;
    my $tablename = shift;
    my $colname = shift;
    my @array;
    my @temp;
    my $sth;
    my $i;
    if (!($sth = $dbh->prepare("SELECT * FROM $tablename"))) {
	die "$main::me: cannot prepare $tablename query ".$dbh->errstr;
    }
    if (!$sth->execute) {
	die "$main::me: cannot execute $tablename query ".$sth->errstr;
    }
    my @labels = @{$sth->{NAME}};
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
