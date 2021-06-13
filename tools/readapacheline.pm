#!/usr/local/bin/perl

# Classify lines in the apache log.
#
# 03/02/06 THVV split out from dash.cgi and sumlog
# 04/18/06 THVV count bytes as well as messages, split command
# 12/27/07 THVV notice the authid
# 11/20/16 THVV warn instead of writing junk
#
# Copyright (c) 2006-2016, Tom Van Vleck

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

# ----------------------------------------------------------------
# example log entry
# ----------------------------------------------------------------
# dsl-201-129-93-128.prod-infinitum.com.mx - - [10/Apr/2006:00:02:09 -0400] "GET /cookie.html HTTP/1.1" 200 7620 "http://search.msn.com/results.aspx?FORM=REIR&q=cookie%20monster" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"
# ----------------------------------------------------------------

package readapacheline;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(readApacheLine);

# ----------------------------------------------------------------
# parse a line from NCSA Combined log file and break into tokens.
#    $val = &readApacheLine($line, $verbose, \%values);
# set symbol table with N items 
# ('domain', 'accesseddir', 'authid', 'accesstime', 'command', 'retcode', 'size', 'referrer', 'browser')
# also ('verb', 'path', 'protocol') broken out of command
# uses global: $main::me for error messages
# returns 0 if line is OK, else 1
sub readApacheLine {
    my $line = shift;
    my $verbose = shift;
    my $vp = shift;

    my $ex;
    my @items;
    my $cursor = 0;
    my $itemx = 0;
    $items[0] = '';
    while ($cursor < length($line)) {
	while (substr($line, $cursor, 1) eq ' ') {
	    $cursor++;		# kill leading blanks
	}
	if (substr($line, $cursor, 1) eq '"') {	# quoted string
	    # inside this string, backslash-quote should be preserved
	    my $ws = '';
	    my $more = 1;
	    $cursor++;
	    while (($more == 1) && ($cursor < length($line))) {
		if (substr($line, $cursor, 2) eq '\\"') {
		    $ws .= '\\"';
		    $cursor++;	# extra bump
		} elsif (substr($line, $cursor, 1) eq '"') {
		    $more = 0;
		} else {
		    $ws .= substr($line, $cursor, 1);
		}
		$cursor++;
	    }
	    $items[$itemx++] = $ws;
	} # quoted string, don't worry about escaped or quoted close-bracket
	elsif (substr($line, $cursor,1) eq '[') { # bracketed string
	    $ex = index(substr($line, $cursor+1), ']');
	    if ($ex < 0) {
		$ex = length($line)-$cursor;
	    }
	    $items[$itemx++] = substr($line, $cursor+1, $ex);
	    $cursor += $ex+2;
	} # bracketed string
	else { # space delimited string
	    $ex = index(substr($line, $cursor), ' ');
	    if ($ex < 0) {
		$ex = length($line)-$cursor;
	    }
	    $items[$itemx++] = substr($line, $cursor, $ex);
	    $cursor += $ex;
	} # space delimited string
    } # while cursor
    return 1 if $items[0] eq ''; # blank line, no fuss
        
    # Record is split into $items.  Interpret and normalize fields.
    # Standard form: DOMAIN DIR USERID TIME COMMAND RETCODE SIZE [REFERRER] [BROWSER]

    $$vp{'referrer'} = '-';
    $$vp{'browser'} = '-';
    $$vp{'domain'} = $items[0]; # where the hit came from
    $$vp{'accesseddir'} = $items[1]; #not used
    $$vp{'authid'} = $items[2]; # if the user logged in, what name he used
    $$vp{'accesstime'} = $items[3]; # time of the hit
    $$vp{'command'} = $items[4]; # HTTP command, e.g. "GET pathname protocol"
    $$vp{'retcode'} = $items[5]; # HTTP ERROR code
    if (!($$vp{'retcode'} =~ /^[0-9]+$/)) { # retcode should be all digits
	warn "$main::me: bad code: $line" if $verbose;
	return 1;
    }
    $$vp{'size'} = $items[6];    # size in bytes
    $$vp{'size'} = 0 if $$vp{'size'} eq '-'; # 304 responses may have a size of hyphen
    if ($$vp{'size'} !~ /^\d+$/) { # Skip this hit if size is not numeric.. ill formed hit record
	warn "$main::me: bad size: $line" if $verbose;
	return 1;
    }
    if ($itemx > 6) { # if there is a referrer string in the log
	$$vp{'referrer'} = $items[7];
	$$vp{'referrer'} = '-' if $$vp{'referrer'} eq '';
    } # if there is a referrer string in the log

    if ($itemx > 7) { # if there is a browser string in the log
	$$vp{'browser'} = $items[8];
    } # if there is a browser string in the log

    # Normalize domain.

    $$vp{'domain'} =~ s/\.$//; # Remove trailing dot from domain

    # Parse the command: "GET pathname protocol" and set some derived items..

    $$vp{'verb'} = '';
    $$vp{'path'} = '';
    $$vp{'protocol'} = '';
    ($$vp{'verb'}, $$vp{'path'}, $$vp{'protocol'}) = split(/ +/, $$vp{'command'}, 3);
    if ($$vp{'path'} eq "") {
	warn "$main::me: cannot parse $$vp{'command'}" if $verbose;
	return 1;
    }
    if ($$vp{'protocol'} !~ /^HTTP/) {
	warn "$main::me: bad protocol $$vp{'command'}" if $verbose;
	return 1;
    }

    return 0;

} # readApacheLine
