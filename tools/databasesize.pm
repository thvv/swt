#!/usr/local/bin/perl

# Ask MySQL for the size of the database using a SHOW TABLE STATUS command and return
# the total database size, number of tables, and the size and number of rows of the
# biggest table.  Tested with MySQL 4.1.20 and 4.1.14.  
#
# USAGE:
#  use databasesize;
#  ($ntables, $totsize, $biggest, $bigsize, $bigrows) = &databaseSize($hostname, $database, $username, $password, $longsw);
#
#  prints a line for each table if $longsw == 1
#
#  returns (0,0,errormessage,0,0) if there is an error.
#  
# NOTES:
#  make sure you keep the username, password, etc in a file secured 600 or 700
#
# 11/14/06 THVV 1.0

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

package databasesize;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(databaseSize psz);

# ================================================================
# Each row fetched contains data like this:
#   Name = xx
#   Engine = MyISAM
#   Version = 9
#   Row_format = Fixed
#   Rows = 2
#   Avg_row_length = 9
#   Data_length = 18
#   Max_data_length = 38654705663
#   Index_length = 1024
#   Data_free = 0
#   Auto_increment = 
#   Create_time = 2006-08-17 13:32:02
#   Update_time = 2006-08-17 13:32:58
#   Check_time = 
#   Collation = latin1_swedish_ci
#   Checksum = 
#   Create_options = 
#   Comment = 

# ================================================================
# ($ntables, $totsize, $biggest, $bigsize, $bigrows) = &databaseSize($hostname, $database, $username, $password);

use DBI;
sub databaseSize {
    my $hostname = shift;
    my $database = shift;
    my $username = shift;
    my $password = shift;
    my $long = shift;

    my $db = DBI->connect("DBI:mysql:$database:$hostname", $username, $password);
    my $sth = 0;

    my $query = "SHOW TABLE STATUS";
    if (!($sth = $db->prepare($query))) {
	#print "cannot prepare $query ".$db->errstr."\n";
	$db->disconnect;
	#exit(0);
	return (0, 0, $db->errstr, 0, 0);
    }
    if (!$sth->execute) {
	#print "cannot execute $query ".$sth->errstr."\n";
	$sth->finish;
	$db->disconnect;
	#exit(0);
	return (0, 0, $sth->errstr, 0, 0);
    }
    my $ntables = $sth->rows;

    my $totsize = 0;
    my $biggest = "";
    my $bigsize = 0;
    my $bigrows = 0;

    @labels = @{$sth->{NAME}};	# get column names.

    while (@array = $sth->fetchrow_array) {
	for ($i=0; $i<@labels; $i++) {
	    $tablecol = @labels[$i];
	    #print " $tablecol = @array[$i]\n";
	    if ($tablecol eq 'Data_length') {
		$dl = @array[$i];
	    } elsif ($tablecol eq 'Index_length') {
		$il = @array[$i];
	    } elsif ($tablecol eq 'Rows') {
		$ro = @array[$i];
	    } elsif ($tablecol eq 'Name') {
		$tn = @array[$i];
	    }
	}
	$s =  $dl + $il;
	$totsize +=$s;
	if (($dl + $il) > $bigsize) {
	    $bigsize =$s;
	    $biggest = $tn;
	    $bigrows = $ro;
	}
	$s = &psz($s);
	print " $tn $s $ro\n" if $long == 1;
    } # while fetchrow
    $sth->finish;
    $db->disconnect;

    return ($ntables, $totsize, $biggest, $bigsize, $bigrows);

} # databaseSize

# $string = &psz($size)
# returns xxG, xxM, xxK, or xx
sub psz {
    my $x = shift;
    my $u = '';
    if ($x > 1073741824) {
	$x = int($x/1073741824+.5);
	$u = 'G';
    } elsif ($x > 1048576) {
	$x = int($x/1048576+.5);
	$u = 'M';
    } elsif ($x > 1024) {
	$x = int($x/1024+.5);
	$u = 'K';
    }
    return $x . $u;
} # psz

