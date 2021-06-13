#!/usr/local/bin/perl
# ---------------- this will fail to load unless GeoIP2::Database::Reader and Try::Tiny are installed
# ---------------- also uses Geo::IP::PurePerl, Socket, MIME::QuotedPrint
# ---------------- the 'use expandfile' drags in readbindxml, readbindsql, DBI, DBD::mysql, XML::libXML, LWP::Simple, Term::AnsiColor
# thvvutil.pm
#
# utility modules for CGIs, use alongside expandfile.pm.
# Copyright (c) 2003-2018 Tom Van Vleck
#
# THVV 12/17/03 1.0 
# THVV 06/30/04 1.1 accept more mail address forms
# THVV 07/01/04 1.2 improve default error tpt and error msgs from legalchars
# THVV 07/18/04 1.3 add unescape
# THVV 08/06/04 1.31 allow double quote in mail subject
# THVV 07/16/05 1.32 add 'cb' and 'yn'
# THVV 08/04/05 1.4 add sendmailmessage2
# THVV 09/12/05 1.41 better error messages
# THVV 01/13/06 1.42 better error messages, can restrict to get or post
# THVV 02/18/06 1.43 better error messages
# THVV 11/21/06 1.44 better error messages, hush switch
# THVV 11/28/06 1.45 better error messages
# THVV 02/08/07 1.46 accept new style config in readconfig
# THVV 04/17/07 1.47 fix bug in readconfig
# THVV 04/29/07 1.5 add reversedns2 and city lookup
# THVV 06/13/07 1.51 vastly speed up city lookup
# THVV 04/29/08 1.52 read tpt files in one op, strict
# THVV 06/26/08 1.6 encode mail subject per RFC 2047
# THVV 06/30/08 1.61 add 'textline' arg type, remove low chars from referrer and userAgent
# THVV 10/24/09 1.62 handle airtelbroadband.in and in-addr.arpa in geoip
# THVV 11/26/09 1.63 handle airtel.in in geoip
# THVV 07/12/10 1.7 add check for required args to getargs2
# THVV 07/21/10 1.71 handle fibertel.com.ar in geoip
# THVV 11/13/13 1.8 use the lite data file for geoip if the heavy file is not present
# THVV 06/06/14 1.81 fix some corner cases in &reversedns2()
# THVV 06/08/18 1.9 update reversedns2 for new MaxMind database format
# THVV 06/09/26 1.91 GeoIP2 throws exceptions GeoIP2::Error::Generic or GeoIP2::Error::IPAddressNotFound for bad or missing IPs: catch them and ignore
# THVV 10/07/18 1.92 use reversedns2() in cgisetup
# THVV 12/11/18 2.0 use expandfile.pm instead of thvve.pm
# THVV 09/13/20 2.1 use expandfile3.pm
# THVV 06/11/21 2.11 expandfile3 => expandfile

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

package thvvutil3;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getargs2 reversedns reversedns2 setup cgisetup logmsg logmsg_env escape unescape percentencode percentdecode twodigit missingparam readtpt err isrobot sendmailmessage sendmailmessage2 fail_with readconfig getCookie);

use expandfile;
use strict;

# ================================================================
# for security, don't put pathnames in args.  Instead,
# - read a config file in cgi-bin
# - bind a "basename" variable in there
# - pass in entrynames as args and concat them onto the basename
# or
# - read in an arg, look it up to get a pathname from config

# ================================================================
# Read GET or POST params, check bad chars, set symbol table
#   &getargs2($controlstring, \%values, \&callbackonstore);
# controlstring is 
#   optional "get" or "post" or empty, followed by
#   a sequence of =argname,type, followed by =
#   the argname can be preceded by ! if the arg is required
# uses global: $ENV $userAgent $referrer
#
# This function looks at the args passed. Each arg must be listed somewhere in $controlstring.
# The type of the arg, from controlstring, selects a check, which the arg value must pass.
# All args marked with ! in controlstring must be supplied.
#
# If an error is found, checkbind -> legalchars -> err -> msg and exit
# prints an error page and calls exit(0) on errors. 
# &err() references $values{'me'} and $values{$values{'me'}.'errpage'} and calls &logmsg() which
# references $values{'timestamp'}, $values{'me'}, $values{'remoteIP'}, $values{'logfile'}
#
sub getargs2 {
    my $validkeys = shift;	# =key,type=key,type=...
    my $symtbp = shift;		# ref to hash
    my $storecallback = shift;	# ref to callback routine for upload
    my ($tainted, @pairs, $pair, $name, $value, $boundary);
    my @wanted = split(/=/, $validkeys); # make an array of key,type pairs
    my %needed;
    foreach (@wanted) {		# if the key begins with ! it is required
	$needed{$1} = $2 if /^!(.*),(.*)/;
    }
    if ($ENV{'CONTENT_TYPE'} =~ /multipart\/form-data; *boundary=(.*)$/i) {
	$boundary = $1;		# can boundary be quoted??
	&process_multipart($boundary, $validkeys, $storecallback, $symtbp, \%needed);
    } else {			# not multipart
	# see if it is GET or POST.
	$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
	if ($ENV{'REQUEST_METHOD'} eq "POST") {
	    if ($validkeys =~ /^get=/i) {
		&errdie("invalid POST");
	    }
	    read(STDIN, $tainted, $ENV{'CONTENT_LENGTH'}); # read whole thing
	} else {	        # if it is OPTIONS (cross domain problem seen by Firefox) this may not work
	    $tainted = $ENV{'QUERY_STRING'}; # GET
	    if ($validkeys =~ /^post=/i) {
		&errdie("invalid GET");
	    }
	}
	# Split supplied arguments into an array of name/value pairs
	$tainted =~ s/&amp;/\&/g; # experiment...
	@pairs = split(/&/, $tainted);
	# Process each pair
	foreach $pair (@pairs) {
	    ($name, $value) = split(/=/, $pair);
	    $value =~ tr/+/ /;
	    $value =~ s/%(..)/pack("C", hex($1))/eg;
	    $name =~ tr/+/ /;
	    $name =~ s/%(..)/pack("C", hex($1))/eg;
	    # look up args in $validkeys and check value versus declared type
	    &checkbind($name, $value, $validkeys, $symtbp, $tainted);
	    delete $needed{$name}; # check off needed arguments
	} # foreach
    } # not multipart
    # all passed args were accepted, check if all required args were given
    my $failmsg = "";
    foreach (keys %needed) {
	$failmsg .= " $_";
	&logmsg("error: required arg '$_' not supplied") if $$symtbp{'trace'} eq 'yes';
    }
    &errdie ("missing args") if $failmsg ne ""; # not saying which ones are missing
} # getargs2

# ----------------------------------------------------------------
# [not exported]
# $string = &legalchars($type, $string);
# check a string for valid characters, returns a valid string
# $type may be
#  'url'       chars allowed in URLs
#  'email'     valid mail address
#  'mailhdr'   chars allowed in a mail header variable like a subject
#  'entryname' word chars, dot, and hyphen only, no slashes
#  'sql'       no apostrophe, no NL
#  'id'        letters, digits, underscore
#  'textline'  arbitrary text but no 000-037
#  'text'      arbitrary text
#  'cb'        Checkbox.  'on' or ''
#  'yn'        Radio button. 'yes' or 'no'
#  '[stuff]'   a type in brackets is a character class, can use \w etc
#  'upload'    .. only for multipart
# uses global: $userAgent $referrer
#
# pushes error page and calls exit(0) if it doesn't like the input.
# calling &err() implicitly references $main::values{'me'}
#
sub legalchars {
    my $type = shift;
    my $arg = shift;
    my $charcl;
    # What about !~`<>|* (shell danger) $^\{}"' hmm
    # what abut unicode escapes? e.g. \u003c = < in facebook .. in document.write
    if ($type eq 'text') { 	# Anything goes.
	$arg =~ s/\0//g;	# .. except null chars
	# .. should we allow %[x]% {{xxx yyy}} and so on?
	# .. i18n chars are not escaped either
	return $arg;
    } elsif ($type eq 'textline') { # a single text line
	$arg =~ tr/\000-\037/!/; # .. no low chars
	# .. should we allow %[x]% {{xxx yyy}} and so on?
	# .. i18n chars are not escaped either
	return $arg;
    } elsif ($type eq 'sql') { 	# SQL type allows anything but takes out NL, NUL and html-escapes apostrophe.
	$arg =~ s/\'/\&\#39;/g;
	$arg =~ s/\n//g;
	$arg =~ s/\0//g;	# .. no null chars
	# .. should we allow %[x]% {{xxx yyy}} and so on?
	# .. i18n chars are not escaped either
	return $arg;
    } elsif ($type eq 'cb') { # Checkbox. 'on' or ''
	return $arg if $arg eq 'on';
	return $arg if $arg eq '';
	&errdie("invalid argument $type '$arg'");
    } elsif ($type eq 'yn') { # Radio button. 'yes' or 'no'
	return $arg if $arg eq 'yes';
	return $arg if $arg eq 'no';
	&errdie("invalid argument $type '$arg'");
    } elsif ($type eq 'email') { # Email address. Has to have atsign and a dot suffix.  "foop@localhost" won't work.
	# what about quotes and whitespace?  Not in this version.
	if ($arg eq '') {
	    return $arg;	# email may be null
	} elsif ($arg =~ /\<([-._+\w]+\@[-+._\w]+\.[\w]+)\>/) {
	    return $1;		# something <name@nam.e>, return without angles
	} elsif ($arg =~ /([-._+\w]+\@[-+._\w]+\.[\w]+) +\(.*\)/) {
	    return $1;		# name@nam.e (something), drop the something
	} elsif ($arg =~ /^[-._+\w]+\@[-+._\w]+\.[\w]+$/) {
	    return $arg;	# name@nam.e
	}
	&errdie("invalid argument $type '$arg'");
    # following tests look for characters that ARE allowed, anything else = error
    } elsif ($type eq 'mailhdr') {
	$charcl = '[\s\[\]\#\(\)\@\'\"%!?\&;:_\-=*^\/.,+\w]'; # Mail subject.  Big thing is no NL. would allow %[x]%
    } elsif ($type eq 'pathname') { 
	# what about .. in pathnames?
	$charcl = '[_\-+.\w/]'; # Pathname. Letters, dot, underscore, hyphen, plus, slash
    } elsif ($type eq 'entryname') { 
	$charcl = '[_\-+.\w]';  # Entryname. Letters, dot, underscore, hyphen, plus
    } elsif ($type eq 'url') { 
	$charcl = '[ \(\)\@\'%!?\&:;_\-=~*^\/.,+\w]'; # url allows tilde (2004)
    } elsif ($type eq 'id') { 
	$charcl = '[=_\w]';     # Identifier: letters, digits, underscore, equal (cause of base64)
    } elsif ($type =~ /^\[.*\]$/) { # Character class type in brackets
	$charcl = $type;	# Just accept what he says.
    } else {
	&errdie("invalid argtype $type $arg");
    }
    if ($arg =~ /^($charcl*)$/) { # see if the string is all valid
	return $1;
    } else {
	my $taint = $arg;
	$taint =~ s/$charcl//g; # isolate bad chars
	$taint = substr($taint, 0,32) if length($taint) > 32;
	$arg = substr($arg, 0,32) if length($arg) > 32;
	&logmsg("error: bad chars '$taint' in $type '$arg' $main::values{'userAgent'} $main::values{'referrer'}");
	&errdie("invalid argument $type $arg");
    }
} # legalchars

# ----------------------------------------------------------------
# bind a value to a name in the symbol table if it is of expected type
# $v = &checkbind($name, $value, $nametypes, $symtbp, $errstring);
sub checkbind {
    my $name = shift;		# supplied arg name
    my $value = shift;		# supplied value
    my $nametypes = shift;	# validkeys string
    my $symtbp = shift;		# ref to symbol table hash
    my $errstring = shift;	# error string
    if ($nametypes ne '') {	    
	if ($nametypes =~ /=!?$name,([^=]+)=/i) {
	    my $type = $1;
	    $value = &legalchars($type, $value);
	} else {
	    &logmsg("error: badkey '$name' not in /$nametypes/ $errstring") if $$symtbp{'trace'} eq 'yes';
	    &errdie("invalid argument '$name'");
	}
    } # if nametypes
    $$symtbp{$name} = $value; # bind in symbol table
    &logmsg("trace: bound $name = $value") if $$symtbp{'trace'} eq 'yes';
} # checkbind

# ................................
# Multipart forms are always POST, so we read args from STDIN.
#	&process_multipart($boundary, $validkeys, $store_callback_func, \%v, \%needed);
# See "form Data Submission" in http://www.w3.org/TR/REC-html40/interact/forms.html
# .. and RFC2388
# .. and RFC2045 (MIME quoting).
# this code is experimental.. file upload case is partially handled... single file only.
# does not handle Content-ID, Content-Description, Content-xxx, MIME-Version
sub process_multipart {
    my $bdy = shift;		# boundary string from $ENV{'CONTENT_TYPE'}
    my $validkeys = shift;	# controlstring
    my $callbackfn = shift;	# function to call when storing
    my $symtbp = shift;		# ref to hash
    my $neededp = shift;	# ref to hash of required args

    my $line;			# line from STDIN
    my $filename;		# filename from STDIN
    my $filepath;		# file path returned from &$callbackfn()
    my $name;			# var name 
    my $value;			# var value
    my $bdy2;			# second boundary for multipart/mixed
    my $mimetype = 'text/plain';
    my $content_transfer = "";
    &logmsg("trace: multipart $bdy") if $$symtbp{'trace'} eq 'yes';
    while (<STDIN>) {	# read and discard leading headers
	s/\r//g;
	chomp;
	$line = $_;
	last if $line =~ /$bdy/i;
	&logmsg("trace: ignored header '$line'") if $$symtbp{'trace'} eq 'yes';
    } # read leading headers
    $line = <STDIN>;	# next line should be Content-disp...
    while (1) {		# read lines till a boundary is found
	$line =~ s/\r//g;
	chomp $line;
	&logmsg("trace: header '$line'") if $$symtbp{'trace'} eq 'yes';
	# TODO multi file uploads will have not have filename
	if ($line =~ /Content-Disposition: *form-data; *name="([^"]*)"; *filename="([^"]*)"$/i) {
	    # File Upload case.
	    # Content-Disposition: form-data; name="upload"; filename="catalytic.1"
	    # This will fail if user's browser doesn't get the quotes right.
	    $name = $1;		# The var name in the <INPUT>.
	    $filename = &legalchars('entryname', $2); # The file name selected. Crap out if bad.
	    if ($validkeys =~ /=!?$name,upload=/i) { # The validkeys arg must say upload is allowed for this name.
		delete $$neededp{$name}; # check off needed arguments
		&logmsg("trace: file upload $name $filename") if $$symtbp{'trace'} eq 'yes';
		if (!defined ($callbackfn)) {
		    &logmsg("error: multipart upload $name $filename with no callbackfn");
		    exit(0); # user sees an error 500
		}
		while (<STDIN>) {	# eat optional headers after Content-Disposition
		    s/\r//g;
		    chomp;
		    $line = $_;
		    last if $line eq ""; # .. until a blank line
		    if ($line =~ /Content-Type: (.*)$/i) { # what about charset=??
			$mimetype = $1;
			&logmsg("trace: mimetype $mimetype") if $$symtbp{'trace'} eq 'yes';
		    } elsif ($line =~ /Content-Type: multipart\/mixed; boundary=(.*)$/i) {
			# TODO multi file uploads will have a Content-disposition: file with a name for each part
			my $bdy2 = $1;
			# specifying a SECOND boundary, followed by blank line, boundary, parts.
			&logmsg("not impl: multi file upload $name $filename");
			exit (0); # not implemented yet??
		    } else {
			&logmsg("error: unk after Content-Disposition: '$line'");
		    }
		} # eat optional
		&logmsg("trace: calling callback pre") if $$symtbp{'trace'} eq 'yes';
		# the callback function is supposed to validate the filename.
		# if it wants to log any messages, it will.
		$filepath = &$callbackfn('pre', $filename); # can I store this file?
		if ($filepath ne "") {
		    # there is no size check here
		    &readwrite($filepath, $bdy, $symtbp, $mimetype, $content_transfer);
		    &logmsg("trace: calling callback post") if $$symtbp{'trace'} eq 'yes';
		    $filepath = &$callbackfn('post', $filename); # do post-download
		} else {
		    $line = &readstdin($bdy); # store denied, flush input till eof or boundary
		}
		# Finished processing the upload, see if there are more inputs.
	    } else {  # upload is not allowed
		&logmsg("error: upload not allowed: $name $filename");
		exit(0);	# fail with error 500 if upload not allowed
	    }
	} elsif ($line =~ /Content-Disposition: *form-data; *name="([^"]*)"$/i) { # what if name not quoted??
	    # If you put enctype="multipart/form-data" on a regular POST form, it comes here, and works.
	    # .. reads multiple lines, concatenates them, and sets a variable.
	    # .. here is where we would do base64 and quoted-printable, but not yet
	    $name = $1;
	    #&logmsg("trace: varname '$name'") if $$symtbp{'trace'} eq 'yes';
	    while (<STDIN>) { # eat up any additional headers after Content-Disposition until blank
		s/\r//g;
		chomp;
		$line = $_;
		last if $line =~ /^$/; # blank ends this eating
		#&logmsg("trace: header '$line'") if $$symtbp{'trace'} eq 'yes';
		if ($line =~ /Content-Type: *(.*)$/i) { # what about charset=??
		    $mimetype = $1;
		    &logmsg("trace: ignored: Content-Type: $mimetype") if $$symtbp{'trace'} eq 'yes';
		} elsif ($line =~ /Content-Transfer-Encoding: *(.*)$/i) {
		    $content_transfer = $1;
		    &logmsg("trace: ignored: Content-Transfer-Encoding: $content_transfer") if $$symtbp{'trace'} eq 'yes';
		} else {
		    &logmsg("not impl: form-data header '$line'"); # ??? unhandled header
		}
	    } # eat up
	    # now comes the value, possibly on multiple lines.
	    $value = &readstdin($bdy);
	    &checkbind($name, $value, $validkeys, $symtbp, "multipart"); # bind the value to the name.
	    delete $$neededp{$name}; # check off needed arguments
	} else {
	    &logmsg("error: malformed '$line'"); # Probably a bug in my rexps.  Fail safely.
	    exit(0);
	}
	#&logmsg("continuing..") if $$symtbp{'trace'} eq 'yes'; 
	# Get another group from stdin, could have multiple form-data blocks.
	$line = <STDIN>;
	last if !$line;
    } # while 1
} # process_multipart

# ................................
# read lines off STDIN and concatenate them until EOF or boundary.
sub readstdin {
    my $boundaryline = shift;
    my $line;
    my $v = '';
    while (<STDIN>) { # Accumulate all data until the boundary.
	s/\r//g;
	chomp;
	$line = $_;
	# TODO base64 and quoted-printable
	last if $line =~ /^-+$boundaryline/;
	$v .= $line; # ravel onto value
    }
    return $v;
} # readstdin

# ................................
# file upload handler.
#    &readwrite($path, $boundary, $symtbp, $mimetype, $content_enc);
# requires write access on the directory that will contain path, for the user this prog is running as.
# TODO decode base64 and quoted-printable
# See RFC 2045
# See also the source for CGI.PM, which does a lot of fancy stuff
# .. to read in until it finds the boundary.  We don't do this, yet.
sub readwrite {
    my $pat = shift; # path to write the file to
    my $bdy = shift; # boundary we are looking for
    my $stp = shift; # \%values in main prog
    my $mtp = shift; # mime type, not sure this is needed
    my $cte = shift; # "" / "7bit" / "8bit" / "binary" / "quoted-printable" / "base64" / ietf-token / x-token
    my $line;
    # if we crash partway through the file will be damaged.
    # could write a temp file and rename it???
    if (!open(WR, ">$pat")) {
	&logmsg("error: cannot write to file '$pat' $!");
	exit(0);
    }
    if ($cte eq "base64") {
	&logmsg("warn: base64 not handled");
	exit(0);
    } elsif ($cte eq "quoted-printable") {
	&logmsg("warn: quoted-printable not handled");
	exit(0);
    } else {			# plain
	while (<STDIN>) { # read and write till boundary
	    $line = $_;
	    #&logmsg("trace: readwrite '$line'") if $$stp{'trace'} eq 'yes';
	    last if $line =~ /^-+$bdy/;
	    print WR $line;
       	}
    } # plain
    close WR;
} # readwrite

# ================================================================
# reversedns(domain) translates numeric URLs into names -- obsolete function
# .. caches its result
# $remoteIP = &reversedns($ip);
# uses global: $main::values{'dnscachefile'}, $main::values{'geoipfile'}
# sets global: -
# reads and writes DNS cache file
sub reversedns {
    my $dom = shift;
    my $vp = \%main::values;
    my $nam = &gethostname($dom, $vp);
    # reads the free MaxMind GeoIP data file
    if ($main::values{'geoipfile'} ne '') {
	if ($dom =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/) { # what about IPV6?  MaxMind does not support
	    my $numval = $4 + 256*($3 + 256*($2 + 256*$1));
	    if (open(GEO, $main::values{'geoipfile'})) {
		while (<GEO>) {
		    # "2.6.190.56","2.6.190.63","33996344","33996351","GB","United Kingdom"
		    if (/".*",".*","(.*)","(.*)","(.*)",".*"/) {
			my $lo = $1;
			my $hi = $2;
			my $cc = $3;
			if (($lo <= $numval)&&($numval <= $hi)) {
			    if ($nam =~ /\.([a-z]*)$/i) {
				last if $1 =~ /$cc/i;
			    }
			    $nam .= '[' . $cc . ']';
			    last;
			}
			last if $lo > $numval;    # file is in sort
		    }
		} # while
		close GEO;
	    } # if open
	} # if dom
    } # if geoipfile
    return $nam;
} # reversedns

# ================================================================
# reversedns2(domain, \%values) translates numeric URLs into domain names with geoip tail
# .. translates 71.238.203.13 => 71.238.203.13_c-71-238-203-13.hsd1.mi.comcast.net[US/Howell MI]
#     $remoteIP = &reversedns2($ip, \%values);
# reads and writes DNS cache file
sub reversedns2 {
    my $dom = shift;
    my $vp = shift;
    $$vp{'country'} = '';
    if ($dom =~ /^(.*)(\[.*\])$/) {
	$dom = $1;		# trim the old geoip
    }
    my $nam = &gethostname($dom, $vp); # see if we can add hostname
    &citylookup2($dom, $vp);	       # look up GeoIP in MaxMind GeoIP2 data
    if ($$vp{'country'} ne '') {
	my $result .= '[';
	$result .= $$vp{'country'};
	if ($$vp{'city'} ne '') {
	    $result .= '/';
	    $result .= $$vp{'city'};
	    if ($$vp{'regionname'} ne '') {
		$result .= ' '. $$vp{'regionname'};
	    }
	}
	$result .= ']';
	$nam .= $result;
    }
    return $nam;
} # reversedns2

# ================================================================
# not exported
# gethostname translates an IP address into "ipaddr_name" if it can
#    $name = &gethostname($ip, \%values);
# If gethostbyaddr() can find the name for an IP, add a space and the name to the end of the IP.
# it looks in the file "dnscache" first.  This file has the same format as other reverse lookup caches.
use Socket;
sub gethostname {
    my $dom = shift;
    my $vp = shift;
    my $answer = $dom;
    my (@adr, $arg, $ali, $typ, $len, @ads, $carg, $cnum, $cnam, $nam);
    my %dnscache_nam;
    my %dnscache_arg;
    if ($$vp{'dnscachefile'} ne '') {
	if (open(DNSCACHE, $$vp{'dnscachefile'})) {
	    # read in the whole dnscache into an associative array
	    while (<DNSCACHE>) {
		chop;
		($carg, $cnum, $cnam) = split (/ /, $_);
		$cnum = '0.0.0.0' if !defined($cnum);
		$dnscache_nam{$cnum} = $cnam;
		$dnscache_arg{$cnum} = $carg;
	    } # while
	    close (DNSCACHE);
	    # check the array
	    if ($dnscache_nam{$dom}) {
		$nam = $dnscache_nam{$dom}; # found, no need to write
		$answer .= ' ' . $nam if $nam ne $answer; # might have cached "couldn't find name"
		#&logmsg("trace: dnscache found $dom -> $nam") if $$vp{'trace'} eq 'yes';
	    } else { # not found
		# TODO - support IPV6 - have to split on colon, get 8 hexpods of 0-4
		$nam = gethostbyaddr(inet_aton($dom), AF_INET);
		if (!defined($nam) || ($nam eq '') || ($nam eq '.') || (index($nam, '.') == -1) || ($nam =~ /\.woo$/) || ($nam =~ /\.gbl$/)) {
		    #&logmsg("trace: gethostbyaddr lookup failed for $dom") if $$vp{'trace'} eq 'yes';
		    $nam = $dom;
		} else {
		    $answer .= '_' . $nam if $nam ne $answer; # success
		}
		$dnscache_nam{$dom} = $nam; # remember result either way
		$dnscache_arg{$dom} = $arg;
		# write out the whole associative array into dnscache
		if (open(DNSCACHE, ">$$vp{'dnscachefile'}")) {
		    foreach (keys %dnscache_nam) {
			$cnam = $dnscache_nam{$_};
			$cnam = '' if !defined($cnam);
			$carg = $dnscache_arg{$_};
			print DNSCACHE "$carg $_ $cnam\n";
		    } # foreach
		    close (DNSCACHE);
		} else {
		    warn "error: $$vp{'dnscachefile'} write err\n";
		} # if open (write)
	    } # not found
	} else {
	    warn "error: $$vp{'dnscachefile'} read err\n";
	} # if open (read)
    } else {
	warn "dnscachefile not specified\n";
    } # if dnscachefile
    return $answer;
} # gethostname

# ================================================================
# not exported
# 06/08/18 - new GeoIP2 database format, old one is no longer updated
# citylookup2(ipaddr) translates an IP address into country/city/regionname
#    &citylookup2($ip, \%values);
# assumes MaxMind city database is in $HOME/lib/GeoLite2-City.mmdb (or in working dir or in /usr/local/share/)
# binds the following in %values: country, city, regionname
# .. regionname is state/province code, ISO/FIPS 
#
# see https://metacpan.org/pod/GeoIP2::Database::Reader for documentation of a sort. then do trial and error.
#
# this will be slow unless libmaxminddb library (http://maxmind.github.io/libmaxminddb/releases)
# .. and MaxMind::DB::Reader::XS are installed
#

use Geo::IP::PurePerl;
use GeoIP2::Database::Reader;
use Try::Tiny;
sub citylookup2 {
    my $dom = shift;
    my $vp = shift;
    my $geoip_version = 'GeoLite2';
    $$vp{'country'} = '';
    $$vp{'city'} = '';
    $$vp{'regionname'} = '';
    # search for the data file.
    # .. need to add code for new way with paid "full" data file
    my $datafile = "$ENV{'HOME'}/lib/GeoLite2-City.mmdb";
    if (!-f $datafile) {
	$datafile = '/usr/local/share/GeoLite2-City.mmdb'; # where Maxmind recommends
    }
    if (!-f $datafile) {
	$datafile = 'GeoLite2-City.mmdb'; # if run cgiwrapped, does not have HOME
    }
    # keep trying if we can't find a data file
    if (!-f $datafile) {
	$geoip_version = 'GeoIPCity'; # could not find new data file, use old way with paid or free data
	$datafile = "$ENV{'HOME'}/lib/GeoIPCity.dat"; # paid
    }
    if (!-f $datafile) {
	$datafile = '/usr/local/share/GeoIPCity.dat'; # paid, where Maxmind recommends
    }
    if (!-f $datafile) {
	$datafile = 'GeoIPCity.dat'; # if run cgiwrapped, does not have HOME, better be in wdir
    }
    if (!-f $datafile) {
	$datafile = "$ENV{'HOME'}/lib/GeoLiteCity.dat"; # could not find paid db, use free
    }
    if (!-f $datafile) {
	$datafile = '/usr/local/share/GeoLiteCity.dat'; # free, where Maxmind recommends
    }
    if (!-f $datafile) {
	$datafile = 'GeoLiteCity.dat'; # free, if run cgiwrapped, does not have HOME
    }
    if (!-f $datafile) {
	return;			# crap, no data file
    }
    # some ISPs encode the IP address BACKWARDS in the reverse DNS name
    my $ok = 0;
    if ($dom =~ /([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})\.in-addr\.arpa/) { 
	$dom = "$4.$3.$2.$1";	# backwards
	$ok = 1;
    } elsif ($dom =~ /([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})\.airtelbroadband\.in/) {
	$dom = "$4.$3.$2.$1";	# backwards
	$ok = 1;
    } elsif ($dom =~ /([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})\.airtel\.in/) {
	$dom = "$4.$3.$2.$1";	# backwards
	$ok = 1;
    } elsif ($dom =~ /([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})\.cust\.bluewin\.ch/) {
	$dom = "$4.$3.$2.$1";	# backwards
	$ok = 1;
    } elsif ($dom =~ /([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})\.fibertel\.com\.ar/) {
	$dom = "$4.$3.$2.$1";	# backwards
	$ok = 1;
    } elsif ($dom =~ /([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})[-\.]([0-9]{1,3})/) { # this will match embedded IPs also
	$dom = "$1.$2.$3.$4";	# forwards
	$ok = 1;
	# TODO - handle IPV6, 8 hexpods of 0-4 -- MaxMind does not handle yet
    }
    if ($ok == 1) {
	if ($geoip_version eq 'GeoLite2') {
	    #warn "using Geolite2 $dom\n";
	    # new way .. does not set as many variables unless you buy Insights service
	    try {
		my $reader = GeoIP2::Database::Reader->new(file => $datafile, locales => [ 'en', ]);
		my $cr = $reader->city( ip => $dom );
		my $cityrec = $cr->city();
		my $cityname = $cityrec->name();
		#warn "cityname $cityname\n";
		my $countryrec = $cr->country();
		my $country_code = $countryrec->iso_code();
		#warn "country_code $country_code\n";
		my $mss = $cr->most_specific_subdivision();
		my $region = $mss->iso_code() if defined ($mss); # check if this works
		#warn "region $region\n";
		$cityname =~ s/\'/\&#39;/g;
		$$vp{'city'} = $cityname;
		$$vp{'country'} = $country_code;
		$region =~ s/\'/\&#39;/g;
		$$vp{'regionname'} = $region if $country_code eq 'US'; # only show state/province for US/CA
		$$vp{'regionname'} = $region if $country_code eq 'CA';
	    } catch {
		# # GeoIP2::Error::Generic or GeoIP2::Error::IPAddressNotFound 
	    }		
	} else {
	    #warn "using GeoIP $dom\n";
	    # old way, paid or free .. sets more variables but nobody uses them
	    my $gi = Geo::IP::PurePerl->new($datafile, Geo::IP::PurePerl->GEOIP_STANDARD());
	    my ($country_code,$country_code3,$country_name,$region,$city,$postal_code,$latitude,$longitude,$dma_code,$area_code) = $gi->get_city_record($dom);
	    $country_code = '' if !defined($country_code);
	    $country_code3 = '' if !defined($country_code3);
	    $country_name = '' if !defined($country_name);
	    $region = '' if !defined($region);
	    $city = '' if !defined($city);
	    $postal_code = '' if !defined($postal_code);
	    $latitude = '' if !defined($latitude);
	    $longitude = '' if !defined($longitude);
	    $dma_code = '' if !defined($dma_code);
	    $area_code = '' if !defined($area_code);
	    $city =~ s/\'/\&#39;/g;
	    $region =~ s/\'/\&#39;/g;
	    $$vp{'locid'} = 'ok';
	    $$vp{'country'} = $country_code;
	    $$vp{'region'} = $region;
	    $$vp{'city'} = $city;
	    $$vp{'postalcode'} = $postal_code;
	    $$vp{'latitude'} = $latitude;
	    $$vp{'longitude'} = $longitude;
	    $$vp{'dmacode'} = $dma_code;
	    $$vp{'areacode'} = $area_code;
	    $$vp{'regionname'} = $region if $country_code eq 'US';
	    $$vp{'regionname'} = $region if $country_code eq 'CA';
	}
    } else {
	# not something we can look up
    }
} # citylookup2

# ================================================================
# Set up timestamp and program name
# &setup('progname');
# uses global: -
# sets global: $main::values{} me, timestamp, year, month, day, hour, minute, unamea, remoteIP, remoteHost, userAgent, referrer, HOME
# sets global: numericIP, userAgent, referrer, remoteIP, numericIP
# I am not happy with the coupling between modules here, shd fix someday.
sub setup {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat);
    $main::values{'me'} = shift;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime(time);
    $year += 1900;		# Perl year is 101 for 2001.
    $main::values{'timestamp'} = "$year".'-'.&twodigit($mon+1).'-'.&twodigit($mday).' '.&twodigit($hour).':'.&twodigit($min);
    $main::values{'year'} = "$year";
    $main::values{'prevyear'} = $year-1;
    $main::values{'month'} = &twodigit($mon+1);
    my @moname = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan');
    $main::values{'monthname'} = $moname[$mon];
    $main::values{'day'} = &twodigit($mday);
    $main::values{'hour'} = &twodigit($hour);
    $main::values{'min'} = &twodigit($min);
    $main::values{'minute'} = &twodigit($min);
    $main::values{'date'} = &twodigit($mday) . ' ' . $moname[$mon] . ' ' . $year;
    # get the system ID and so on
    my $s = `uname -a`;
    chomp $s;
    $main::values{'unamea'} = $s; # in case we need this
    # get the HTTP environment, used in error messages
    $main::numericIP = $ENV{'REMOTE_ADDR'}; # get the IP
    $main::userAgent = $ENV{'HTTP_USER_AGENT'}; # browser as specified by user agent
    $main::userAgent =~ tr/\000-\037/./; # user could put crap in this
    $main::referrer = $ENV{'HTTP_REFERER'}; # referrer as specified by user agent
    $main::referrer =~ tr/\000-\037/./; # user could put crap in this
    $main::remoteIP = $main::numericIP;
    $main::values{'remoteIP'} = $main::remoteIP;
    $main::values{'remoteHost'} = $main::remoteIP;
    $main::values{'userAgent'} = $main::userAgent;
    $main::values{'referrer'} = $main::referrer;
    $main::values{'HOME'} = $ENV{'HOME'};
} # setup

# ================================================================
# Set up timestamp, program name, version, configuration, and template.  Calls reversedns.
# This is only for wrapped CGIs since it reads the config file, which contains database passwords.
# does not accept old style config file
#   $template = &cgisetup(\%values, 'progname', 'uconfig.htmt', 'index.htmt');
# uses global: -
# sets global: me, version, timestamp, year, month, day, hour, minute, monthx, monthname, monthno, tpt, unamea
# sets global: numericIP, remoteIP, remoteHost, userAgent, referrer, HOME, remoteUser
# **** depends on expandstring and expandblocks
sub cgisetup {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat);
    my $symtbp = shift;		# ref to hash
    $$symtbp{'me'} = shift;
    $$symtbp{'version'} = shift;
    my $configName = shift;
    my $tptName = shift;
    # ---------------- new style readconfig, file should begin with % ----------------
    if ($configName ne "") {
	$configName = &legalchars('entryname', $configName); # must be valid name in current dir
	my $c = '';
	$/ = undef;
	if (open(TPT, "$configName")) {
	    $c = <TPT>;
	    close(TPT);
	} else {
	    &errdie("cannot open $configName $!");
	}
	$/ = "\n";
	my $junk = &expandstring($c, $symtbp); # executed for side effect on %values
    }
    # ---------------- read the clock and bind a few well known constants ----------------
    my @moname = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan');
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime(time);
    $year += 1900;		# Perl year is 101 for 2001.
    $$symtbp{'year'} = "$year";
    $$symtbp{'prevyear'} = $year-1;
    $$symtbp{'monthname'} = $moname[$mon];
    $$symtbp{'month'} = $moname[$mon];
    $$symtbp{'monthx'} = &twodigit($mon+1); # obsolete
    $$symtbp{'monthno'} = &twodigit($mon+1);
    $$symtbp{'day'} = &twodigit($mday);
    $$symtbp{'hour'} = &twodigit($hour);
    $$symtbp{'min'} = &twodigit($min);
    $$symtbp{'minute'} = &twodigit($min);
    $$symtbp{'date'} = &twodigit($mday) . ' ' . $moname[$mon] . ' ' . $year;
    $$symtbp{'timestamp'} = "$year".'-'.&twodigit($mon+1).'-'.&twodigit($mday).' '.&twodigit($hour).':'.&twodigit($min);
    # ---------------- get the server's ID and so on ----------------
    my $s = `uname -a`;
    chomp $s;
    $$symtbp{'unamea'} = $s; # in case we need this
    # ---------------- get web server vars and do reverse DNS, used in error messages ----------------
    $$symtbp{'remoteUser'} = $ENV{'REMOTE_USER'}; # user name if user logged in
    $$symtbp{'numericIP'} = $ENV{'REMOTE_ADDR'}; # numeric IP
    $$symtbp{'remoteHost'} = $$symtbp{'numericIP'}; # will have host name
    $$symtbp{'remoteIP'} = $$symtbp{'numericIP'}; # will have both
    $$symtbp{'userAgent'} = $ENV{'HTTP_USER_AGENT'};
    $$symtbp{'userAgent'} =~ tr/\000-\037/./; # user could put crap in this
    $$symtbp{'referrer'} = $ENV{'HTTP_REFERER'};
    $$symtbp{'referrer'} =~ tr/\000-\037/./; # user could put crap in this
    $$symtbp{'HOME'} = $ENV{'HOME'};
    $$symtbp{'remoteHost'} = &reversedns2($$symtbp{'numericIP'}, $symtbp) if $$symtbp{'numericIP'} =~ /^\d+\.\d+\.\d+\.\d+$/;
    $$symtbp{'remoteIP'} .= " ($$symtbp{'remoteHost'})" if $$symtbp{'remoteHost'} ne $$symtbp{'remoteIP'};
    $$symtbp{'remoteIP'} .= " <$$symtbp{'remoteUser'}>" if $$symtbp{'remoteUser'} ne '';
    # ---------------- read in a template and bind its blocks ----------------
    my $tpt = '';
    if ($tptName ne '') {
	$$symtbp{'tpt'} = &legalchars('entryname', $tptName); # must be valid name in current dir
	$tpt = &readtpt('tpt');
	$tpt = &expandblocks($tpt, $symtbp);
    }
    return $tpt;		# return the template
} # cgisetup

# ================================================================
# Log a message with timestamp and programname.  Output $main::values{'remoteIP'} if known
# &logmsg($msg);
# uses global: $main::values{'timestamp'}, $main::values{'me'}, $main::values{'remoteIP'}, $main::values{'logfile'}
# sets global: -
sub logmsg {
    my $msg = shift;
    $msg = substr($msg, 0, 255) if length($msg) > 255; # don't fill the log with garbage (132 was too small)
    $msg = &sanitize($msg); # don't put control chars in the log
    my $logfile = 'log.txt';
    $logfile = $main::values{'logfile'} if $main::values{'logfile'} ne '';
    if (open(LOG, ">>$logfile")) {
	print LOG "$main::values{'timestamp'} $main::values{'me'} $main::values{'remoteIP'} $msg\n";
	close LOG;
    }
} #logmsg

# ================================================================
# Log a message with timestamp and programname and dump environment vars.
# &logmsg_env($msg);
# uses global: $ENV
# sets global: -
sub logmsg_env {
    my $msg = shift;
    &logmsg($msg);
    for (keys %ENV) {		# dump environment
        &logmsg("  $_ $ENV{$_}");
    }
} # logmsg_env

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
    $x =~ s/%/%25/g;  # 3/17/14
#     # character entities .. does not work
#     $x =~ s/à/\&agrave;/g;
#     $x =~ s/á/\&aacute;/g;
#     $x =~ s/á/\&acirc;/g;
#     $x =~ s/á/\&atilde;/g;
#     $x =~ s/å/\&aring;/g;
#     $x =~ s/ã/\&auml;/g;
#     $x =~ s/á/\&aelig;/g;
#     $x =~ s/ç/\&ccedil;/g;
#     $x =~ s/è/\&egrave;/g;
#     $x =~ s/é/\&eacute;/g;
#     $x =~ s/ê/\&ecirc;/g;
#     $x =~ s/ë/\&euml\;/g;
#     $x =~ s/ì/\&igrave\;/g;
#     $x =~ s/í/\&iacute\;/g;
#     $x =~ s/î/\&icirc\;/g;
#     $x =~ s/ï/\&iuml\;/g;
#     #$x =~ s/x/\&eth\;/g;
#     $x =~ s/ñ/\&ntilde\;/g;
#     $x =~ s/ò/\&ograve\;/g;
#     $x =~ s/ó/\&oacute\;/g;
#     #$x =~ s/x/\&ocirc\;/g;
#     $x =~ s/õ/\&otilde\;/g;
#     $x =~ s/õ/\&ouml\;/g;
#     #$x =~ s/÷/\&divide\;/\g;
#     $x =~ s/ø/\&oslash\;/g;
#     $x =~ s/ù/\&ugrave\;/g;
#     $x =~ s/ú/\&uacute\;/g;
#     $x =~ s/û/\&ucirc\;/g;
#     $x =~ s/ü/\&uuml\;/g;
#     #$x =~ s/x/\&yacute\;/g;
#     #$x =~ s/x/\&thorn\;/g;
#     #$x =~ s/x/\&yuml\;/g;
#     $x =~ s/â/\&acircumflex\;/g;
#     # what about caps
    return $x;
} # escape

# ================================================================
# Convert a string from HTML to plain ASCII
# $s = &unescape($s);
# uses global: -
# sets global: -
sub unescape {
    my $x = shift;
    $x =~ s/\&\#39;/\'/g;
    $x =~ s/\&gt;/\>/g;
    $x =~ s/\&lt;/\</g;
    $x =~ s/\&quot;/\"/g;
    $x =~ s/\&amp;/\&/g;
    # convert char entities to closest ascii
    $x =~ s/\&szlig\;/ss/g;
    $x =~ s/\&agrave\;/a/g;
    $x =~ s/\&aacute\;/a/g;
    $x =~ s/\&acirc\;/a/g;
    $x =~ s/\&atilde\;/a/g;
    $x =~ s/\&auml\;/a/g;
    $x =~ s/\&aring\;/a/g;
    $x =~ s/\&aelig\;/a/g;
    $x =~ s/\&ccedil\;/c/g;
    $x =~ s/\&egrave\;/e/g;
    $x =~ s/\&eacute\;/e/g;
    $x =~ s/\&ecirc\;/e/g;
    $x =~ s/\&euml\;/e/g;
    $x =~ s/\&igrave\;/i/g;
    $x =~ s/\&iacute\;/i/g;
    $x =~ s/\&icirc\;/i/g;
    $x =~ s/\&iuml\;/i/g;
    $x =~ s/\&eth\;/e/g;
    $x =~ s/\&ntilde\;/n/g;
    $x =~ s/\&ograve\;/o/g;
    $x =~ s/\&oacute\;/o/g;
    $x =~ s/\&ocirc\;/o/g;
    $x =~ s/\&otilde\;/o/g;
    $x =~ s/\&ouml\;/o/g;
    $x =~ s/\&divide\;/\//g;
    $x =~ s/\&oslash\;/o/g;
    $x =~ s/\&ugrave\;/u/g;
    $x =~ s/\&uacute\;/u/g;
    $x =~ s/\&ucirc\;/u/g;
    $x =~ s/\&uuml\;/u/g;
    $x =~ s/\&yacute\;/y/g;
    $x =~ s/\&thorn\;/t/g;
    $x =~ s/\&yuml\;/y/g;
    $x =~ s/\&acircumflex\;/a/g;
    $x =~ s/\&#174\;/(R)/g;
    # what about caps
    return $x;
} # unescape

# ================================================================
# Percent-encode punctuation in a string
# Javascript "escape()" function
# $s = &percentencode($s);
# uses global: -
# sets global: -
sub percentencode {
    my $x = shift;
# what abbout chars > 177
# for ($i=0; $i>length($x); $i++) {
#     my $y = ord substr($x, $i, 1);
#     if ($y > 127) {
# 	my $hx = sprintf("%lx ", $y);
# 	$hx = "0$hx" if length($hx) < 3;
# 	substr($x, $i, 1) = '%' . $hx;
#     }
# }
    $x =~ s/\%/%25/g; # Percent (do first)
    $x =~ s/\&/%26/g;
    $x =~ s/\"/%34/g;
    $x =~ s/\</%3C/g;
    $x =~ s/\>/%3E/g;
    $x =~ s/ /%20/g;  # space
    $x =~ s/\'/%22/g;
    $x =~ s/\#/%23/g;
    $x =~ s/\$/%24/g;
    $x =~ s/\+/%2B/g;
    $x =~ s/,/%2C/g;
    $x =~ s/\//%2F/g;
    $x =~ s/:/%3A/g;
    $x =~ s/;/%3B/g;
    $x =~ s/=/%3D/g;
    $x =~ s/\?/%3F/g;
    $x =~ s/\@/%40/g;
    $x =~ s/\{/%7B/g; #   Left Curly Brace
    $x =~ s/\}/%7D/g; #   Right Curly Brace
    $x =~ s/\|/%7C/g; #   Vertical Bar/Pipe
    $x =~ s/\\/%5C/g; #   Backslash
    $x =~ s/\^/%5E/g; #   Caret
    $x =~ s/\~/%7E/g; #   Tilde
    $x =~ s/\[/%5B/g; #   Left Square Bracket
    $x =~ s/\]/%5D/g; #   Right Square Bracket
    $x =~ s/\`/%60/g; #   Grave Accent 	
    # instead of percent-encoding these, translate them to dots.
    $x =~ tr/\000-\037/./; # NUL through US
    return $x;
} # percentencode

# ================================================================
# Percent-decode a string
# Javascript "unescape()" function
# 	$s =~ s/%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg; # urldecode
# $s = &percentdecode($s);
# uses global: -
# sets global: -
sub percentdecode {
    my $x = shift;
    $x =~ s/%26/\&/g;
    $x =~ s/%34/\"/g;
    $x =~ s/%3C/\</g;
    $x =~ s/%3E/\>/g;
    $x =~ s/%20/ /g;
    $x =~ s/%22/\'/g;
    $x =~ s/%23/\#/g;
    $x =~ s/%24/\$/g;
    $x =~ s/%2B/+/g;
    $x =~ s/%2C/,/g;
    $x =~ s/%2F/\//g;
    $x =~ s/%3A/:/g;
    $x =~ s/%3B/;/g;
    $x =~ s/%3D/=/g;
    $x =~ s/%3F/\?/g;
    $x =~ s/%40/\@/g;
    $x =~ s/%7B/\{/g; #   Left Curly Brace
    $x =~ s/%7D/\}/g; #   Right Curly Brace
    $x =~ s/%7C/\|/g; #   Vertical Bar/Pipe
    $x =~ s/%5C/\\/g; #   Backslash
    $x =~ s/%5E/\^/g; #   Caret
    $x =~ s/%7E/\~/g; #   Tilde
    $x =~ s/%5B/\[/g; #   Left Square Bracket
    $x =~ s/%5D/\]/g; #   Right Square Bracket
    $x =~ s/%60/\`/g; #   Grave Accent 	
    $x =~ s/%25/\%/g; # Percent (do last)
    return $x;
} # percentdecode

# ================================================================
# prettifier for dates
# $val = &twodigit ($field)
# uses global: -
# sets global: -
sub twodigit {			# returns field with leading zero if necessary
    my $x = shift;
    return "$x" if ($x > 9);
    return "0$x";
} # twodigit

# ================================================================
# Print out an error if a parameter is missing
# exit(0) if &missingparam('name');
# uses global: -
# sets global: -
# returns 1 if error found, else 0
sub missingparam {
    my $key = shift;
    if ((!defined($main::values{$key})) || ($main::values{$key} eq '')) {
	print "Content-Type: text/html\n\n" unless $main::values{'hush'};
	print &err("error: $key not defined") unless $main::values{'hush'};
	return 1;
    }
    return 0;
} #missingparam

# ================================================================
# Read in and return a template. Return an error string if you can't.
# $template = &readtpt('tptnamekey');
# uses global: $main::values{$tptnamekey}
# sets global: -
# returns a template string to be expanded later
# on error, returns an internal template
sub readtpt {
    my $tptnamekey = shift;
    my $tptname = $main::values{$tptnamekey};
    if (($tptname eq '') || ($tptname =~ /^([_\-.\w]*)$/)) { # tptname can only have letters, underscore, hyphen, dot
	my $tpt = '';
	$/ = undef;
	if (open(TPT, "$tptname")) {
	    $tpt = <TPT>;	# accumulate template
	    close(TPT);
	    $/ = "\n";
	    return $tpt;
	} else {
	    $/ = "\n";
	    return "<html></body><h1>Template Missing</h1>$tptnamekey $tptname missing $!</body></html>";
	}
    } else {
	return "<html></body><h1>Template Missing</h1>$tptnamekey $tptname unset or illegal</body></html>";
    }
} # readtpt

# ================================================================
# Find an error template and expand it.  Also log the error message.
# print "Content-Type: text/html\n\n";$e = &err($msg);print $e;
# uses global: $main::values{'me'}, $main::values{$main::values{'me'}.'errpage'};
# sets global: $main::values{'errormessage'}
# returns an expanded HTML string, without the content-type heading
# **** depends on expandstring
sub err {
    my $em = shift;
    &logmsg($em);		# this sanitizes and trims too
    $em = substr($em, 0, 132) if length($em) > 132; # first 132 is enough
    $main::values{'errormessage'} = &escape(&sanitize($em)); # avoid cross site scripting and control chars
    # find the template and read it in
    my $x;
    my $tt = '';
    my $t = $main::values{$main::values{'me'}.'errpage'};
    if ($t eq '') {		# if no errtpt
	$tt = "<html> <head> <title>Error</title> <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\"> </head> <body> <h1>Error</h1> Sorry! There was an error. <table> <tr><td><b>errormessage</b></td><td>$main::values{errormessage}</td></tr>\n";
	if ($main::values{'trace'} eq 'yes') {
	    for (keys %main::values) { # dump environment except for password
		$x = $main::values{$_};
		$tt .= "<tr><td>$_</td><td>$x</td></tr>" if $_ ne 'errormessage' && $_ ne 'password';
	     } # for
	} # if trace
	$tt .= "</table> </body> </html>\n";
	return &expandstring($tt, \%main::values);
    } # if no errtpt
    $t = &legalchars('entryname', $t); # ensure valid err tpt name
    $/ = undef;
    if (open(TPT, $t)) {	# template must be in same dir as CGI
	$tt = <TPT>;		# accumulate template
	close(TPT);
	$/ = "\n";
	return &expandstring($tt, \%main::values);
    }
    $/ = "\n";
    return "<html><body><h1>An Error Occurred</h1>$main::values{'errormessage'}<p>$t missing</body></html>";
} # err

# ================================================================
# Check to see if the caller of a CGI is a robot.
# this could be vastly expanded.
# $x = &isrobot($remoteIP, $userAgent, $referrer);
# uses global: -
# sets global: -
sub isrobot {
    my $ip = shift;
    my $ua = shift;
    my $rf = shift;

    # crawlers have no business in here.
    if ($ip =~ /googlebot/) {
	return 1;
    } elsif ($ip =~ /inktomisearch/) {
	return 1;
    }

    # guess it's OK
    return 0;
} # isrobot

# ================================================================
# send a mail message
# ***** depends on expandstring()
# &sendmailmessage($envAddr, $toAddr, $fromAddr, $subject, $tpt, \%values)
# uses global: $main::values{'mailprog'}
# sets global: -
# logs an error if it can't open the mail program.
#
# template should begin with
# %[remoteIP| X-Sender-IP: |\n]%%[userAgent|X-Sender-UA: |\n]%%[referrer|X-Referrer: |\n]%X-Mailer: %[me]% %[version]%
# then a blank line, and 
# %[text]%
# 
sub sendmailmessage {
    my $envAddr = shift;
    my $toAddr = shift;
    my $fromAddr = shift;
    my $subject = shift;
    my $tpt = shift;
    my $symtp = shift;
    $subject = &encode_header($subject);
    $envAddr = &legalchars('email', $envAddr);
    $toAddr = &legalchars('email', $toAddr);
    $fromAddr = &legalchars('email', $fromAddr);
    if (open (MAIL, "|$$symtp{'mailprog'} -i $envAddr")) { # ignore standalone dots, envelope address is user
	print MAIL "Return-Path: $fromAddr\n";
	print MAIL "From: $fromAddr\n";
	print MAIL "To: $toAddr\n";
	print MAIL "Subject: $subject\n";
	print MAIL &expandstring($tpt, $symtp);
	print MAIL "\n";
	close (MAIL);
	&logmsg("trace: sent $subject to $toAddr") if $$symtp{'trace'} eq 'yes';
    } else {
	&logmsg("error: can't open $$symtp{'mailprog'} $!");
    }
} # sendmailmessage

# same as above but lets you specify the "sender" separately
# &sendmailmessage2($senderAddr, $envAddr, $toAddr, $fromAddr, $subject, $tpt, \%values)
# needed for spf
# ***** depends on expandstring()
sub sendmailmessage2 {
    my $senderAddr = shift;
    my $envAddr = shift;
    my $toAddr = shift;
    my $fromAddr = shift;
    my $subject = shift;
    my $tpt = shift;
    my $symtp = shift;
    $subject = &encode_header($subject); # RFC2047
    $senderAddr = &legalchars('email', $senderAddr);
    $envAddr = &legalchars('email', $envAddr);
    $toAddr = &legalchars('email', $toAddr);
    $fromAddr = &legalchars('email', $fromAddr);
    if (open (MAIL, "|$$symtp{'mailprog'} -i $envAddr")) { # ignore standalone dots, envelope address is user
	print MAIL "Return-Path: $senderAddr\n";
	print MAIL "Sender: $senderAddr\n";
	print MAIL "From: $fromAddr\n";
	print MAIL "To: $toAddr\n";
	print MAIL "Subject: $subject\n";
	print MAIL &expandstring($tpt, $symtp); # the tpt should escape anything it wants to.. notice that the tpt should have headers, NLNL, text
	print MAIL "\n";
	close (MAIL);
	&logmsg("trace: sent $subject to $toAddr") if $$symtp{'trace'} eq 'yes';
    } else {
	&logmsg("error: can't open $$symtp{'mailprog'} $!");
    }
} # sendmailmessage2

# ----------------------------------------------------------------
# convert headers per RFC2047
#   $value = &encode_header($s);
use MIME::QuotedPrint;
sub encode_header {
    my $s = shift;
    my @w = split(/\s+/, $s);
    my @a = ();
    foreach my $word (@w) {
	if ($word =~ /[^[:alpha:]\<\>\.\@\_\-]/) {
	    $word = '=?ISO-8859-1?Q?' . encode_qp($word) . '?=';
	    $word =~ s/\n//;	# WTF
	}
	push @a, $word;
    }
    return join " ", @a;
} # encode_header
# ================================================================
# log an error, expand a failure template
# &fail_with($tpt, $msg);
# uses global: $main::db, $main::sth
# sets global: $main::values{'errormessage'}
# does not return, exits
# ***** depends on expandstring()
sub fail_with {
    my $tpt = shift;
    my $msg = shift;
    $main::values{'errormessage'} = $msg;
    &logmsg($msg);
    print "Content-Type: text/html\n\n";
    print &expandstring($tpt, \%main::values);
    $main::sth -> finish if $main::sth != 0;
    $main::db->disconnect if $main::db != 0;
    exit(0);
} #fail_with

# ================================================================
# Read in and bind config file.
# Accepts old or new style, depending on file name
#   &readconfig($configName, \%values);
# ***** depends on expandstring()
sub readconfig {
    my $configName = shift;
    my $symtbp = shift;
    $configName = &legalchars('entryname', $configName);  # must be valid name in current dir
    if ($configName =~ /\.htmi$/) {
	my $c = '';
	$/ = undef;
	if (open(CFG, "$configName")) {
	    $c = <CFG>;
	    close(CFG);
	    $/ = "\n";
	} else {
	    $/ = "\n";
	    &errdie("cannot open $configName $!");
	}
	my $junk = &expandstring($c, $symtbp);
    } else {
	if (open(CFG, $configName)) {
	    while (<CFG>) {
		chomp;
		if (/^\#/) {
		    # ignore comments in config file
		} elsif (/^(\S+)\t+(.*)$/) { # name <tab> value
		    $$symtbp{$1} = $2;
		    #&logmsg("bound $1 = $2");
		}
	    } # while
	    close(CFG);
	} else {
	    &errdie("cannot open $configName $!");
	}
    }
} # readconfig

# ================================================================
# $v = &getCookie($name)
sub getCookie {
    my $name = shift;
    my $tainted = $ENV{'HTTP_COOKIE'};
    my $clean;
    my @oreos;
    my ($cookieName, $cookieVal);
    if ($tainted =~ /^([ \@\';:_\-=\/.,+\w><]+)$/) {
	$clean = $1;
    } else {
	$clean = "";
	&logmsg("warn: bad cookie '$tainted'") if $tainted ne '';
    }
    @oreos = split(/; /, $clean);
    foreach(@oreos) {
	($cookieName, $cookieVal) = split (/=/, $_);
	#&logmsg("cookie $cookieName=$cookieVal");
	if ($cookieName eq $name) {
	    return $cookieVal;
	}
    }
    return "";
} # getCookie

# ================================================================
# Sanitize a string for printing in error messages (internal, not exported)
# called from logmsg and err
#    $s = &sanitize($s);
sub sanitize {
    my $s = shift;
    $s =~ tr/ -~/?/c; # change anything not space thru tilde to ?
    return $s;
} # sanitize

# ================================================================
# Print user message and die (internal, not exported)
#    &errdie($s);
# reads global: $main::values{'hush'}
sub errdie {
    my $s = shift;
    my $m = &err("error: $s");	# causes logging, returns HTML
    print "Content-Type: text/html\n\n" unless $main::values{'hush'};
    print "$m" unless $main::values{'hush'};
    exit(0);
} # errdie

1;
