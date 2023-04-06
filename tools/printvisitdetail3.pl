#!/usr/local/bin/perl
#
#  Usage: perl printvisitdetail.pl >> report.sql
#
# todo: retry the db reads, display alarms in a color, list each alarm once
#
# Copyright 2006-2020, Tom Van Vleck
#
# 04/28/06 THVV
# 05/27/06 THVV 1.1 generalize criteria for printing
# 07/03/06 THVV 1.2 add event log merge
# 07/11/06 THVV 1.3 show local query attached to filename
# 07/18/06 THVV 1.31 handle case where no visits selected better
# 07/21/06 THVV 1.32 don't fail if can't query the log
# 07/21/06 THVV 1.33 add subtitle
# 08/01/06 THVV 1.34 remove title and subtitle
# 09/21/06 THVV 1.35 minor fix for refspam
# 11/07/06 THVV 1.36 minor fix for summary of visits
# 11/10/06 THVV 1.4 Add count of boring files
# 12/27/06 THVV 1.5 Show pathname instead of filename
# 01/10/07 THVV 1.51 put class=indexer on dt as well as dd
# 02/08/07 THVV 1.52 add -config
# 06/09/07 THVV 1.6 add showanyway table to show graphics if referrer and filename match
# 06/09/07 THVV 1.61 Remove wtcumdom, add wtdomhist, should have done this a long time ago
# 09/17/07 THVV 1.62 Correct session counter
# 01/08/08 THVV 1.63 output authid if nonblank.
# 08/12/08 THVV 1.7 Handle more general log queries. Evaluate log entry printing criteria.
# 08/14/08 THVV 1.8 allow different suffixes visible on short and long report
# 08/16/08 THVV 1.81 Fix bug in merging log entries after the last hit.
# 12/06/08 THVV 1.9 Add code to show sessions that are alarming.
# 12/04/09 THVV 1.91 Shorten alarm.
# 06/04/10 THVV 1.92 Repair broken log merge.
# 09/17/11 THVV 1.93 add count of 404s per visit and good pages per visit.
# 12/07/11 THVV 1.94 if google omits the query, don't print garbage
# 06/03/12 THVV 1.941 if any google omits the query, don't print garbage
# 04/30/15 THVV 1.95 detect and count repeated hits
# 08/24/15 THVV 1.951 handle missing query
# 04/04/16 THVV 2.0 add watchlist
# 01/27/17 THVV 2.1 fix loadhash to make 2 entries, with www and without
# 07/22/19 THVV 2.11 change DL COMPACT to DL STYLE="display: compact" which is still flagged by W3C
# 11/13/20 THVV 2.2 expandfile3
# 06/11/21 THVV 2.21 expandfile3 => expandfile
# 03/27/23 THVV 2.3 add additional vars from visits table for use in print criteria: ninvisit, htmlinvisit, graphicsinvisit, duration
#
# Reads the SQL database and writes HTML
# Originally written in HTMX but was very slow, 2:20 instead of 7 seconds
# 
# Reading all hits in one big SELECT was blowing out memory with the return values.
# logvisits computes a table, hitslices, that breaks the hits into slices.
# 
# This program reads hits selected by the SELECT in visit number order and hit order within visit.
# It formats the visit as a DT with the time and a DD with the details.
# The details are formatted as 
# - requesting IP name or number
# - for each page
# --- page name
# --- query or referrer
# --- time on page
# - visit summary, number of hits, KB, browser
# - visit class
#
# The visit is output if criteria are met:
# -- result of evaluating user supplied HTMX line
# 
# Environment Parameters
# - printvisitdetail_qpvd - SQL query, all hits joined with visits, wtretcodes, wtsuffixclass
# - printvisitdetail_qlog - SQL query, optional, query the event log for tx today
# - criteria - optional expression to expand for side effect to test if visit to be printed, sets "print"
# - logcriteria - optional expression to expand for side effect to test if log entry to be printed, sets "logprint"
# - sufdetails - which column is used to determine visibility of a file, in form "wtsuffixclass.sufdetailslong"
#
# Loads in the table "wtlocalreferrerregexp" of regexps to determine if a domain is local... could do this with LOJ.

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
use strict;

my $me = "printvisitdetail";
my $version = '2.21';
my $configName = '';
my $verbose = 0;
while ($#ARGV >= 0) {
    my $arg = shift;
    if ($arg eq "-v") {
	$verbose = 1;
    } elsif (($arg eq "-e") || ($arg eq "-config")) {
	$configName = shift;
    } else {
	die "$me $version: invalid argument $arg";
    }
}
if ($configName eq '') {
    die "Usage: $me -e config";
}

# ================ obtain parameters ================
my $query1 = $ENV{'printvisitdetail_qpvd'};
die "$me: printvisitdetail_qpvd not set in environment" if $query1 eq '';
my $logq = $ENV{'printvisitdetail_qlog'};
$main::criteria = $ENV{'criteria'};
$main::logcriteria = $ENV{'logcriteria'};
my $sufdetailsflag = $ENV{'sufdetails'};
print "<!-- criteria=$main::criteria logcriteria=$main::logcriteria sufdetailsflag=$sufdetailsflag -->\n";
$sufdetailsflag = 'wtsuffixclass.sufdetailslong' if $sufdetailsflag eq '';

my %v;
$v{'me'} = $me;
$v{'hitsinvisit'} = 0;
$v{'pagesinvisit'} = 0;
$v{'visitgoodpages'} = 0;
$v{'visit404pages'} = 0;
$v{'visitboringpages'} = 0;
$v{'bytesinvisit'} = 0;
$v{'queriesinvisit'} = 0;

my $lastreferrer = ""; # should these be $main::
my $visitblock = "";
my $filehits = "";
my $oldvn = "";
my $timebase = "";
my %seenthisurl;
my %seenthisdomain;

my $c = &loadfile($configName, \%v);
$v{'_xf_currentfilename'} = $configName;
my $junk = &expandstring($c, \%v);
die "$me: $configName did not set hostname" if $v{'_xf_hostname'} eq '';
$v{'_xf_currentfilename'} = "";

# ================ Open the database ================
my $db;
my $tries = 1;
my $sleeptime = 1;
my $maxtries = 9; 	# see if database comes back in 510 seconds
while ($tries < $maxtries) {
    sleep $sleeptime if $sleeptime > 1;
    if (($db = DBI->connect("DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}", $v{'_xf_username'}, $v{'_xf_password'}))) {
	last;		# success
    }
    $tries++;
    $sleeptime *= 2;
}
if ($tries >= $maxtries) {
    print "$me: cannot open DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}, $v{'_xf_username'}\n";
    exit(0);
}

# ================ load in the list of local referrers ================
@main::localdomregex = &loadtable('wtlocalreferrerregexp', 'regex');
# load a list of overrides for graphics to show anyway
&loadhash('wtshowanyway', 'referrer', 'pathrexp', \%main::show_anyway);

# ================ initialize the lists of required and allowed hits ================
# someoday this will be loaded from the database
@main::required_hits = ();
@main::required_hits_count = ();
@main::allowed_hits = ('.');
@main::allowed_referrers = ('.');
@main::allowed_retcode = ('200','304'); # 206, 302, 302, 400, 403, 500 are all filtered by the SELECT, 404 will show up
# ---------------- authus alarm filtering ----------------
# will find broken sessions, sessions touching other than expected files, sessions referred from strange places, funny error codes.
# problem with required_hits: sessions at the beginning and end of the day.
# if ($authus) {
#     @main::required_hits = ('authus.js','authenticator.swf','localstore.swf','lwicon.swf');
#     @main::allowed_hits = ('prod\\/images\\/authus','images\\/logos','authus-defaultdata.cgi','authus.css','authus-verify.cgi','authus-log.cgi','get-icons-js.cgi','reports\\/');
#     @main::allowed_referrers = ('^http:\\/\\/(.*\\.)?lussori.com','^https:\\/\\/authenticator\\.authus\\.com','^https?:\\/\\/www\\.authus\\.com','^http:\\/\\/server.iad.liveperson.net');
#     $main::criteria .= '%[*if,ne,alarm,="",*set,&print,=1]%';
# }
# ================ initialze switches ================
$main::nsess = -1;			# the first flush is not really a visit
$main::nsess_printed = 0;
$main::totalboring = 0;
$main::newdomains = 0;
$main::newreferrers = 0;
$main::inred = 0;
$main::eventcutofftime = 0;

# query the event log for events today
$main::glb_nextlog = 0;		# when this is 0  we won't try to read the event log
$main::glb_nlog = 0;
my @logtables;
my @loglabels;
if ($logq ne "") {		# if event log query supplied
    if (!($main::logh = $db->prepare($logq))) { # it was already expanded by the shell script
	print "$me: cannot prepare $logq ".$db->errstr . "\n";
	$main::glb_nextlog = 0; # when this is 0  we won't try to read the event log
    } else {
	if (!$main::logh->execute) {
	    print "$me: cannot execute $logq ".$main::logh->errstr . "\n";
	    $main::glb_nextlog = 0; # when this is 0  we won't try to read the event log
	} else {
	    @main::loglabels = @{$main::logh->{NAME}}; # get column names.
	    @main::logtables = @{$main::logh->{'mysql_table'}}; # .. and table names
	    $main::glb_nlog = $main::logh->rows; # .. and the number of rows
	    $main::glb_nextlog = &read_one_log_entry($main::logh); # find the time of the first entry
	    print "  <!-- xxlog $logq: $main::glb_nlog events, first=$main::glb_nextlog -->\n";
	}
    }
} # if event log query supplied

print "  <dl style=\"display: compact;\">\n";
# query the slice table .. can't necessarily query the whole hit table 
#   CREATE TABLE hitslices(
#    sllo INT, -- lowest visit number
#    slhi INT  -- last visit number
#   );
my $hsq = "SELECT * FROM hitslices";
my $sliceh;
if (!($sliceh = $db->prepare($hsq))) {
    print "$me: cannot prepare $hsq ".$db->errstr . "\n";
    $main::logh->finish if $main::logh != 0;
    $db->disconnect;
    exit(0);
}
if (!$sliceh->execute) {
    print "$me: cannot execute $hsq ".$sliceh->errstr . "\n";
    $sliceh->finish;
    $main::logh->finish if $main::logh != 0;
    $db->disconnect;
    exit(0);
}
my @hslab = @{$sliceh->{NAME}}; # get column names.
my @hsval;
while (@hsval = $sliceh->fetchrow_array) { # loop on slices
    my $i;
    for ($i=0; $i<@hslab; $i++) {
	my $tablecol =  $hslab[$i];
	$v{$tablecol} = $hsval[$i];
	#print "bound $tablecol = $hsval[$i]\n";
    }
    # here is the query on the hits
    # -- visitdata query, will be expanded to handle hit slices
    # -- ('visitdata','vq','SELECT * FROM hits INNER JOIN wtretcodes ON hits.retcode = wtretcodes.code LEFT OUTER JOIN wtsuffixclass ON hits.filetype = wtsuffixclass.suf
    # --                    WHERE vn >= %[sllo]% AND vn <= %[slhi]% AND wtretcodes.good != 0 ORDER BY hits.vn, hits.sn'),
    my $xq = &expandstring($query1, \%v); # compute a new query1, expanding the WHERE clause on vn
    my $sth;
    if (!($sth = $db->prepare($xq))) {
	print "$me: cannot prepare $xq ".$db->errstr . "\n";
	$sliceh->finish;
	$main::logh->finish if $main::logh != 0;
	$db->disconnect;
	exit(0);
    }
    if (!$sth->execute) {
	print "$me: cannot execute $xq ".$sth->errstr . "\n";
	$sth->finish;
	$sliceh->finish;
	$main::logh->finish if $main::logh != 0;
	$db->disconnect;
	exit(0);
    }
    my @labels = @{$sth->{NAME}}; # get column names.
    my @tables = @{$sth->{'mysql_table'}}; # .. and table names
    my @array;
    # for each returned row
    while (@array = $sth->fetchrow_array) {
	for ($i=0; $i<@labels; $i++) {
	    my $tablecol = $tables[$i].'.'.$labels[$i]; # pay attention, this is subtle, sets $v{'hits.field'} to a value
	    $v{$tablecol} = $array[$i];
	    #print "bound $tablecol = $array[$i]\n";
	}
	&process_one_hit(); # ------ actually process the hit
    } # while fetchrow
    $sth->finish;
} # loop on slices

&flush_visit();			# flush final one
if (defined($ENV{'lastdatebin'}) && ($ENV{'lastdatebin'} > $main::eventcutofftime)) { # in the command environment?
    $main::eventcutofftime = $ENV{'lastdatebin'}; # get the last date for any hit
}
&flush_eventlog($main::eventcutofftime+60);
print "  </dl>\n";
my $eventcomment = '';
$eventcomment = ", $main::glb_nlog events" if $main::glb_nlog > 0;
print "  <p>Displayed $main::nsess_printed visits out of $main::nsess, $main::newdomains new visitors, $main::newreferrers new referrers, $main::inred watched pages, $main::totalboring boring$eventcomment.</p>\n";

$sliceh->finish;
$main::logh->finish if $main::logh != 0;
$db->disconnect;
exit(0);

# ================================================================
# Called once for each hit
# Uses global: $oldvn $filehits $timebase %v
# Sets global: $oldvn $filehits $timebase %v
sub process_one_hit {
    my $pn;
    my $localquery;

    if ($oldvn ne $v{'hits.vn'}) { # if visit number has changed
	&flush_visit();
	&flush_eventlog($main::eventcutofftime+15); #flush event log entries preceding the hit starting the next visit
	&open_visit();
    }
    $oldvn = $v{'hits.vn'};
    $v{'hitsinvisit'}++;
    $v{'bytesinvisit'} += $v{'hits.txsize'};
    my $pathrex;
    my $show = 0;
    if ($v{$sufdetailsflag} ne 0) { # this looks at either wtsuffixclass.sufdetailsshort or sufdetailslong, set by the query
	$show = 1; # if the suffix class says "add to details"
    } else {
	$pathrex = $main::show_anyway{$v{'hits.referrerurl'}}; 
	if ($pathrex ne '') { # if referred by a gallery index
	    if ($v{'hits.path'} =~ /$pathrex/) { # .. and if file is in /images
		$show = 1; # show even though it is a jpg
	    }
	}
    }
    # ----------------------------------------------------------------
    # Alarm detectors
    # loop over required_hits, check name against each, if found increment required_hits_count[i] .. will check this at flush_visit
    my $found = 0;
    my $i;
    for ($i=0; $i<@main::required_hits; $i++) {
	$pathrex = $main::required_hits[$i];
	if ($v{'hits.path'} =~ /$pathrex/) {
	    $main::required_hits_count[$i]++;
	    $found = 1;
	    last;
	}
    } # for
    # else loop over allowed_hits, check name against each, if none are found, alarm++
    if ($found == 0) {
	for ($i=0; $i<@main::allowed_hits; $i++) {
	    $pathrex = $main::allowed_hits[$i];
	    if ($v{'hits.path'} =~ /$pathrex/) {
		$found = 1;
		last;
	    }
	} # for
	if (@main::allowed_hits != 0 && $found == 0) { # empty list means all allowed
	    $v{'alarm'} .= ' badhit' if index($v{'alarm'}, 'badhit') == -1; # do once
	    print "<!-- alarm hit not allowed $v{'hits.path'} -->\n" if $verbose;
	}
    } # for
    # loop over allowed_retcode, if not an allowed server return code, alarm++
    my $bump = 1;
    for (@main::allowed_retcode) { # why error
	if ($v{'hits.retcode'} eq $_) {
	    $bump = 0;
	    last;
	}
    }
    if ($bump == 1) {
	$v{'alarm'} .= ' retcode' if index($v{'alarm'}, 'retcode') == -1; # do once
	print "<!-- alarm retcode $v{'hits.retcode'} -->\n" if $verbose;
    }
    # loop over allowed_referrers, if referrer is not found anywhere, alarm++
    if ($v{'hits.referrerurl'} ne '') {
	$bump = 1;
	for (@main::allowed_referrers) {
	    if ($v{'hits.referrerurl'} =~ /$_/) {
		$bump = 0;
		last;
	    }
	} # for
	if (@main::allowed_referrers != 0 && $bump == 1) { # empty list means all allowed
	    $v{'alarm'} .= ' badref' if index($v{'alarm'}, 'badref') == -1; # do once
	    print "<!-- alarm referrer not allowed $v{'hits.referrerurl'} -->\n" if $verbose;
	}
    }
    # ----------------------------------------------------------------
    if ($main::oldshownpath eq $v{'hits.path'}) { # same as previous hit
	# .. what do we do about oldretcode .. assume they are all the same ignoring 200/206
	$main::sequentialhits++;
	$show = 0;
    }
    if (($main::sequentialhits > 0) && ($main::oldshownpath ne $v{'hits.path'})) { # different from previous hit
	$filehits .= &flush_sequentialhits();
    }
    if ($show) {		# if this hit is to be shown
	$v{'pagesinvisit'}++;
	if ($v{'wtboring.borfilename'} ne '') {	# if this is a boring page, set by LOJ
	    $v{'visitboringpages'} += $v{'wtboring.borweight'}; # add up inhibit-count, criteria may compare to pagesinvisit
	    $main::totalboring++;			      # whole visit may be inhibited if all hits boring
	} elsif ($v{'hits.retcode'} ne '404') {
	    $v{'visitgoodpages'}++;	# boring pages and 404s do not count as good. criteria use this to see if 404s outnumber goods.
	}
	if ($v{'hits.retcode'} eq '404') {
	    $v{'visit404pages'}++;	# criteria use this to see if 404s outnumber goods.
	}
	if ($v{'pagesinvisit'} != 1) { # compute time between pages and append to previous file's name
	    my $timedelta = $v{'hits.systime'} - $timebase;
	    $timedelta = 0 if $timedelta < 0; # in case hits are out of order
	    $filehits .= " ";
	    $filehits .= &formatsecs($timedelta); # convert seconds to mm:ss
	    $filehits .= ", ";
	} # compute time between pages
	if ($v{'wtretcodes.css'} ne '') { # is it in a class based on retcode -- overrides the filename's class
	    $filehits .= "<span class=\"";
	    $filehits .= $v{'wtretcodes.css'};
	    $filehits .= "\">";
	} elsif ($v{'wtcolors.colorclass'} ne '') { # is it in a class based on filename, set by LOJ
	    $filehits .= "<span class=\"";
	    $filehits .= $v{'wtcolors.colorclass'};
	    $filehits .= "\">";
	    $v{'wtcolorfiles'}++; # flag nonblank color so criteria can see it
	    $main::inred++;
	}  # is it in a class based on filename
	$pn = $v{'hits.path'};
	$pn =~ s/^\///;		  # trim leading slash
	$filehits .= &escape($pn); # add the path name to the output
	if ($v{'hits.myquery'} ne '') { # if there is a local query
	    $filehits .= '?';
	    $localquery = &escape($v{'hits.myquery'});
	    $localquery =~ s/^(................................).*$/$1/; # trim to 32 chars
	    $filehits .= $localquery;
	}
	# closing this here means that the time between pages is always black, and the referrer is also not colored.
	# .. that's the easiest to code.
	if (($v{'wtcolors.colorclass'} ne "") || ($v{'wtretcodes.css'} ne "")) {
	    $filehits .= "</span>"; # only close it once
	}
	$timebase = $v{'hits.systime'};
	$v{'queriesinvisit'} += &addreferrer();		# add a referrer if any, and count queries for criteria
	$main::oldshownpath = $v{'hits.path'};
    } # if this hit is to be shown
} # process_one_hit

# ----------------
# convert systime to mm:ss
sub formatsecs {
    my $param1 = shift;
    my $m = int($param1 / 60);
    my $s = int($param1 % 60);
    my $r = "00" . $s;
    $r =~ s/^.*(..)$/$1/;
    return $m . ':' . $r;
} # formatsecs
# ----------------
# Add a referrer after the filename if the referrer has changed.
# Uses global: $lastreferrer $filehits %seenthisurl
# Sets global: $lastreferrer $filehits %seenthisurl
#   $nquey = &addreferrer();
sub addreferrer {
    my $retval = 0;		# 1 if there was an external query, else 0
    my $urlpart = $v{'hits.referrerurl'};
    my $querypart = $v{'hits.referrerquery'};
    foreach (@main::localdomregex) {
	if ($urlpart =~ /$_/i) {
	    $urlpart = 'local';
	    last;
	}
    }
    my $testval = $urlpart . '?' . $querypart;
    if ($testval ne $lastreferrer) {
	if (($urlpart ne '') && ($urlpart ne 'local')) {
	    $filehits .= " ";
	    my $trimmed = &escape($urlpart);
	    $trimmed =~ s/^.*?:\/\///; # remove http
	    $trimmed =~ s/\/.*$//;     # remove first slash and after
	    $trimmed =~ s/\.(com|net)$//; # remove well known domains
	    $trimmed =~ s/^(search|www)\.//; # remove well known prefixes
	    if (($urlpart =~ /^http/) && ($querypart eq '')) {
		$filehits .= " <a href=\"";
		$filehits .= $v{'hits.referrerurl'}; # don't trim this one -- but it could be dangerous to click
		$filehits .= "\">(";
		my $new_referrer = 0;
		my $close_span = 0;
		if ($v{'wtcumref.refurl'} eq '') { # set by LOJ .. nonblank if referrerurl has been seen already
		    # mark the referrer as "new" if never seen before
		    if (!defined($seenthisurl{$v{'hits.referrerurl'}})) {
			$new_referrer = 1;
			$close_span = 1;
			$filehits .= "<span class=\"newref\">";
			$main::newreferrers++;
			$v{'newreferrers'}++;
		    }
		    $seenthisurl{$v{'hits.referrerurl'}} ++;
		} elsif ($v{'wtreferrercolor.rcurl'} ne "") {
		    # mark the referrer in color if its color is registered
		    $close_span = 1;
		    my $foo = $v{'wtreferrercolor.rcclass'};
		    $filehits .= "<span class=\"$foo\">";
		    $v{'wtcolorfiles'}++;
		}
		$urlpart =~ s/^(................................................................).*$/$1/;
		$filehits .= &escape($urlpart); # shorten the ref on the page to 64 chars
		$filehits .= "</span>" if $close_span == 1;
		$filehits .= ")</a>";
	    } elsif ($querypart ne '') {
		$filehits .= "<span class=\"query\">(";
		if ($querypart eq '(encoded)') { # encoded query from one of the googles, etc, replaced in logvisits.pl
		    # google and yahoo encode the query for HTTPS accesses, leading to junk in the report.
		    $filehits .= $trimmed; # just say (google.ie)
		} elsif (($trimmed =~ /^google/) && ($querypart !~ /q=/) && ($querypart =~ /=/)) { # no query string from one of the googles, but a lot of junk
		    $filehits .= $trimmed; # just say (greeble)
		} else {
		    $querypart = &escape($querypart);
		    $querypart =~ s/^(................................................................).*$/$1/;
		    $filehits .= $trimmed . ': ' . $querypart; # 64 chars for query is plenty
		}
		$filehits .= ")</span>";
		$retval = 1;
	    } else {
		$filehits .= "(";
		$filehits .= $trimmed; # urlpart that doesn't begin with http
		$filehits .= ")";
	    }
	}
    } # if $urlpart ne $lastreferrer
    $lastreferrer = $testval;
    return $retval;		# return 1 if there was a query, else 0
} # addreferrer

# ================================================================
# If the same file was hit N times, put out a number in brackets
# Uses global: $main::sequentialhits
# Sets global: $main::sequentialhits
sub flush_sequentialhits {
    my $n = $main::sequentialhits+1;
    my $result = "[" . $n . "x]";
    $main::sequentialhits = 0;
    $main::oldshownpath = '';
    return $result;
} # flush_sequentialhits

# ================================================================
# Finish the currently open visit block.
# Write it out if it meets criteria, otherwise ignore it.
# Uses global: $visitblock $filehits
# Sets global: $visitblock
sub flush_visit {
    if ($main::sequentialhits > 0) { # if any leftover sequential hits
	$filehits .= &flush_sequentialhits();
    }
    # loop over required_hits_count, and if any are 0, then alarm++
    my $found = 0;
    my $i;
    for ($i=0; $i<@main::required_hits_count; $i++) {
	if ($main::required_hits_count[$i] == 0) {
	    $v{'alarm'} .= ' missing' if index($v{'alarm'}, 'missing') == -1; # do once
	    print "<!-- alarm missing $main::required_hits[$i] -->\n" if $verbose;
	}
    } # for

    if ($v{'watchop'} eq 'S') { # if this visit is to be summarized, hide the details .. invent a control later
	$filehits = '<span class="starthidden">' . $filehits . '</span>';
    }
    
    $visitblock .= $filehits;		       # visitblock is the string with time, domain. filehits is the list of files hit.
    $visitblock .= ' <span class="sessd">[';   # append visit data trailer
    $visitblock .= $v{'hitsinvisit'};	       # .. hits in visit
    $visitblock .= ', ';		       # .. comma
    my $kbinvisit = int($v{'bytesinvisit'}/1024);
    $visitblock .= $kbinvisit;	               # .. bytes in visit
    $visitblock .= ' KB';		       # .. KB
    if ($v{'browser'} ne '') {
	$visitblock .= ', <span class="brow">'; # .. browser
	$visitblock .= $v{'browser'};          # should shorten this any???
	$visitblock .= '</span>';
    }
    $visitblock .= $v{'alarm'};                # .. flag if there were alarming events in this visit
    $visitblock .= ']</span>';                 # close visit data trailer
    if (($v{'vclass'} ne '') || ($v{'authid'} ne '')) {
	$visitblock .= '<span class="vc"> {';  # append visit class ID
	$visitblock .= $v{'vclass'};
	# $visitblock .= ' '.$v{'source'};     # DEBUG append the source
	$visitblock .= ':' if $v{'authid'} ne '';
	$visitblock .= $v{'authid'};           # append user login name if nonblank
	$visitblock .= '}</span>';
    }

    if ($v{'watchnote'} ne '') {               # watchlist provided annotation
	$visitblock .= ' <span class="flg">('; # flag the color
	$visitblock .= $v{'watchnote'};
	$visitblock .= ')</span>';
    }

    #$visitblock .= ' '.$v{'visitboringpages'};	# DEBUG
    $visitblock .= "</dd>\n";                  # append </DD> and NL
    
    # Print the visit if it has any pages and meets criteria.
    # -- example: "%[*set,&print,=0]%%[*if,ge,alarm,=1,*set,&print,=1]%"
    # on the first visit, $v{'pagesinvisit'} will be 0.
    # The expression evaluated can test $v{'pagesinvisit'}, $v{'newreferrers'}, $v{'wtcolorfiles'}, etc
    if ($v{'pagesinvisit'} > 0) { # graphic-only visits will not display
	if ($v{'watchop'} eq 'H') {
	    $v{'print'} = '0';	# if watch list says hide, we hide
	} elsif ($v{'watchop'} eq 'I') {
	    $v{'print'} = '1';	# if watch list says important, set print to 1
	} else {		# .. otherwise execute user criteria
	    $v{'print'} = '1';	# default if no criteria
	    my $junk = &expandstring($main::criteria, \%v); # execute a statement for side effect, may change "print"
	}
	if ($v{'print'} eq '1') {
	    print "$visitblock\n";
	    $main::nsess_printed++; # count visits printed for ending comment
	} elsif ($v{'print'} eq '0') {
	    #print "<dt>Suppressed: print = ($v{'print'}), pagesinvisit = $v{'pagesinvisit'}.</dt>\n";
	} else {
	    print "<dt>error: print = ($v{'print'})</dt>\n";
	}
    }
    $main::nsess++;		# count total visits for ending comment
    #.. this counts "visits" with no HTML, all 404 visits, etc. is that what we want?
} # flush_visit

# ================================================================
# If there are event log entries that precede the start of the new visit, put it out.
#   &flush_eventlog($time);
sub flush_eventlog {
    my $cutoff = shift;
    while (($main::glb_nextlog > 0) && ($cutoff > $main::glb_nextlog)) {
	$v{'logprint'} = '1';	# default if no criteria
	my $junk = &expandstring($main::logcriteria, \%v); # execute a statement for side effect, may change "logprint"
	if ($v{'logprint'} eq '1') {
	    print "      <dt class=\"logtime\">$v{'logtimeformatted'}</dt><dd class=\"logtext\">$v{'logtext'}</dd>\n";
	} elsif ($v{'logprint'} eq '0') {
	    #print "<dt>Suppressed: print = ($v{'logprint'}), $v{'logtimeformatted'}</dt><dd class=\"logtext\">$v{'logtext'}</dd>\n";
	} else {
	    print "<dt>error: logprint = ($v{'logprint'})</dt>\n";
	}
	$main::glb_nextlog = &read_one_log_entry($main::logh);
    }
} # flush_eventlog

# ================================================================
# Open a new visit.
# Uses global: %seenthisdomain
# Sets global: $visitblock %seenthisdomain $lastreferrer $filehits
sub open_visit {
    $v{'browser'} = $v{'visits.browsername'}; # get the pretty name from the visit
   $v{'ninvisit'} = $v{'visits.ninvisit'};
   $v{'htmlinvisit'} = $v{'visits.htmlinvisit'};
   $v{'graphicsinvisit'} = $v{'visits.graphicsinvisit'};
   $v{'bytesinvisit'} = $v{'visits.bytesinvisit'};
   $v{'duration'} = $v{'visits.duration'};
    $v{'vclass'} = $v{'visits.visitclass'};
    $v{'source'} = $v{'visits.source'};
    $v{'authid'} = $v{'visits.authid'};
    $v{'watchop'} = $v{'visits.watchop'};
    $v{'watchnote'} = $v{'visits.watchnote'};
    $v{'visitdomain'} = $v{'hits.domain'}; # so criteria can see it
    $v{'newdomain'} = 0;
    $main::eventcutofftime = $v{'hits.systime'} if ($v{'hits.systime'} > $main::eventcutofftime);
    my $ddclass = ($v{'vclass'} eq 'indexer') ? ' class="indexer"' : '' ;
    $visitblock = "      <dt$ddclass>";       # output <DT>
    # Format the time, from SQL timestamp to just hh:mm
    my $time = $v{'.stamp'};
    $time =~ s/^....-..-.. (..:..).*$/$1/;
    $visitblock .= $time;                     # output time stamp
    $visitblock .= "</dt><dd$ddclass>";	      # output </DT><DD class="indexer"> or </DT><DD>
    my $domc = 'refdom';
    if ($v{'wtdomhist.dhdom'} eq '') {        # if LOJ found no match, we have not seen it before
	if (!defined($seenthisdomain{$v{'hits.domain'}})) {
	    $domc = 'firstrefdom';
	    $v{'newdomain'}++;
	    $main::newdomains++;
	}
	$seenthisdomain{$v{'hits.domain'}} ++;
    }
    $domc .= ' authsess' if $v{'authid'} ne ''; # if user gave password
    $visitblock .= "<span class=\"$domc\">"; # output <SPAN CLASS="refdom">
    $visitblock .= &escape($v{'hits.domain'}); # output domain name
    $visitblock .= "</span> -- ";	      # output </SPAN> -- 
    # -------TODO add the star if this is a local hit
    $v{'hitsinvisit'} = 0;
    $v{'pagesinvisit'} = 0;
    $v{'visitgoodpages'} = 0;
    $v{'visit404pages'} = 0;
    $v{'visitboringpages'} = 0;
    $v{'bytesinvisit'} = 0;
    $v{'wtcolorfiles'} = 0;	# count files whose names are in red, etc
    $v{'newreferrers'} = 0;	# count referrer links in red
    $v{'alarm'} = '';	        # switch that will show an unusual visit
    $v{'queriesinvisit'} = 0;
    # loop over required_hits_count, set all to 0
    my $i;			# reset alarm counter
    for ($i=0; $i<@main::required_hits; $i++) {
	$main::required_hits_count[$i] = 0;
    } # for
    $lastreferrer = "";
    $filehits = "";
    $main::sequentialhits = 0;	# reset sequential-hits counter
    $main::oldshownpath = '';	# reset previous filename
} # open_visit

# ================================================================
sub read_one_log_entry {
    my $logh = shift;
    my $nextlogtime = 0;
    my @logarray;
    if (@logarray = $logh->fetchrow_array) {
	my $tn;
	my $i;
	for ($i=0; $i<@main::loglabels; $i++) {
	    $tn = $main::logtables[$i];
	    $tn = 'wtlog' if $tn eq '';
	    my $logcol = $tn.'.'.$main::loglabels[$i];
	    $v{$logcol} = $logarray[$i];
	    #print "<!-- xxlog bound $logcol = $logarray[$i]-->\n";
	}
	$nextlogtime = $v{'wtlog.logtime'};
	$v{'logtimeformatted'} = $v{'wtlog.logtimeformatted'};
	$v{'logtimeformatted'} =~ s/^....-..-.. (..:..).*$/$1/;
	$v{'logtext'} = $v{'wtlog.logtext'};
    }
    #print "  <!-- xxlog read one entry, next is $nextlogtime -->\n";
    return $nextlogtime;
} # read_one_log_entry

# ================================================================
# load a one column SQL table into an array
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
    my @labels = @{$sth->{NAME}};
    my $i;
    for ($i=0; $i<@labels; $i++) {
	last if $labels[$i] eq $colname;
    } # for
    die "$me: column $colname not found in $tablename" if $i >= @labels;
    my @array;
    while (@array = $sth->fetchrow_array) {
	push @temp, $array[$i];
    }
    $sth->finish;
    return @temp;
} # loadtable

# ================================================================
# load two columns of SQL table into a local hash
# @list = &loadhash($tablename, $col1name, $col2name, \%hash);
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
    my @labels = @{$sth->{NAME}};
    my $i1 = -1;
    my $i2 = -1;
    my $i;
    for ($i=0; $i<@labels; $i++) {
	$i1 = $i if $labels[$i] eq $col1name;
	$i2 = $i if $labels[$i] eq $col2name;
    } # for
    die "$me: column $col1name not found in $tablename" if $i1 == -1;
    die "$me: column $col2name not found in $tablename" if $i2 == -1;
    my @array;
    while (@array = $sth->fetchrow_array) {
	if ($array[$i1] ne '') {  # do not add if key is blank
	    $$vp{$array[$i1]} = $array[$i2]; # do with www.
	    $array[$i1] =~ s/\/www\./\//;
	    $$vp{$array[$i1]} = $array[$i2]; # do without www.
	}
    }
    $sth->finish;
} # loadhash
# ================================================================
# Convert a string to safe HTML
# $s = &escape($s);
# uses global: -
# sets global: -
sub escape {
    my $x = shift;
    $x =~ s/\&/\&amp;/g;
    $x =~ s/\"/\&quot;/g;
    $x =~ s/\</\&lt;/g;
    $x =~ s/\>/\&gt;/g;
    $x =~ s/\'/\&\#39;/g;
    return $x;
} # escape

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
