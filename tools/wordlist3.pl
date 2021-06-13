#\!/usr/local/bin/perl
#
# wordlist3.pl
#  get the list of words from queries, load into a table
#
# Usage:
# perl wordlist3.pl -config config2.htmi wtyquerywords | mysql

# DROP TABLE IF EXISTS wtquerywords;
# CREATE TABLE wtyquerywords (word VARCHAR(255) PRIMARY KEY, count INT);
# SELECT word, wcount FROM wtyquerywords ORDER BY wcount DESC LIMIT 50;

# THVV 10/10/11 1.0
# THVV 10/12/11 1.1 break on all punc
# THVV 09/22/15 1.2 ignore encoded queries
# THVV 07/31/19 1.3 ignore long words
# THVV 09/13/20 1.4 expandfile3
# THVV 06/11/21 1.41 expandfile3 => expandfile

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

my $configName = 'config2.htmi'; # The one in mxs
my $version = '1.41';

use expandfile;
use DBI;
&setup3("wordlist3");	# Nonstandard setup.

my %v = {};

my $tablename = '';

while ($#ARGV >= 0) {
    my $arg = shift;
    if (($arg eq "-config") || ($arg eq "-e")) {
	$configName = shift;
	my $config = &loadfile($configName, \%v);
	$v{'_xf_currentfilename'} = $configName;
	my $junk = &expandstring($config, \%v); # config file is a template, expand it
	die "$me: $configName did not set _xf_hostname" if $v{'_xf_hostname'} eq '';
	die "$me: $configName did not set _xf_database" if $v{'_xf_database'} eq '';
	die "$me: $configName did not set _xf_username" if $v{'_xf_username'} eq '';
	die "$me: $configName did not set _xf_password" if $v{'_xf_password'} eq '';
    } else {
	$tablename = $arg;
    }
} # while

die "$me: specify tablename" if $tablename eq '';
$v{'_xf_currentfilename'} = $tablename;

my %stopw;
my $stop = "0,1,2,3,4,5,6,7,8,9,a,all,an,and,any,are,as,at,b,be,been,between,both,but,by,c,could,d,did,do,does,e,else,et,etc,every,f,few,for,from,g,get,go,got,h,had,has,have,he,her,here,him,his,how,i,if,in,into,is,it,its,j,k,l,m,may,me,might,more,most,much,must,my,n,near,not,o,of,off,on,one,only,or,other,our,out,over,p,q,r,s,so,some,t,than,that,the,their,them,then,there,these,they,this,those,though,through,thus,to,too,two,u,v,w,was,we,were,what,when,where,which,who,why,will,with,within,without,www,x,y,yes,yet,you,your,z";
foreach (split(/,/,$stop)) {
    $stopw{$_} = 1;
}

my $count = 0;

my $db;
my $sth;
if (!($db = DBI->connect("DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}", $v{'_xf_username'}, $v{'_xf_password'}))) {
    print "cannot open DBI:mysql:$v{'_xf_database'}:$v{'_xf_hostname'}, $v{'_xf_username'}\n";
    exit(1);
}

# Fetch all the rows with a query
my $query = "SELECT referrerquery FROM hits WHERE referrerquery != ''";
if (!($sth = $db->prepare($query))) {
    print "error preparing $query " . $db->errstr . "\n";
    exit(1);
}
if (!$sth->execute) {
    print "cannot execute $query ".$sth->errstr . "\n";
    exit(1);
}

my $numrows = $sth->rows;
$v{'numrows'} = $numrows;
@labels = @{$sth->{NAME}};	# get column names.
    
while (@array = $sth->fetchrow_array) {
    for ($i=0; $i<@labels; $i++) {
	$v{"$labels[$i]"} = $array[$i]; # bind returned values
    }
    next if $v{'referrerquery'} eq '(encoded)'; # encoded queries are not interesting
    next if $v{'referrerquery'} =~ /=/; # discard those where the query wasn't extracted
    next if $v{'referrerquery'} =~ /^cache:/; # discard cache queries
    next if length($v{'referrerquery'}) > 100; # assholes
    
    $v{'referrerquery'} =~ tr/[A-Z][a-z][0-9]:.\/-_/ /c; # change all breaking punc to space
    $v{'referrerquery'} =~ tr/[A-Z]/[a-z]/; # lowercase
    $v{'referrerquery'} =~ s/  +/ /g; # compress blanks
    $v{'referrerquery'} =~ s/^ //; # remove leading
    @y = split(/ /, $v{'referrerquery'});
    foreach (@y) {
	if (!defined($stopw{$_})) {
	    print "INSERT INTO $tablename VALUES('$_', 1) ON DUPLICATE KEY UPDATE wcount=wcount+1;\n";
	    $count++;
	}
    } # foreach word
} # while
$sth->finish;
$db->disconnect;

print "-- $count $numrows\n";

# ================================================================
# slightly modified timestamp
sub setup3 {
    $v{'me'} = $_[0];
    @moname = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan');
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime(time);
    $year += 1900;
    $v{'year'} = $year;
    $v{'day'} = &twodigit($mday);
    $v{'month'} = $moname[$mon];
    $v{'hour'} = &twodigit($hour);
    $v{'min'} = &twodigit($min);
    $v{'date'} = &twodigit($mday) . ' ' . $moname[$mon] . ' ' . $year;
    $v{'timestamp'} = "$year".'-'.&twodigit($mon+1).'-'.&twodigit($mday).' '.&twodigit($hour).':'.&twodigit($min);
    $v{'monthx'} = &twodigit($mon+1);
    $v{'minute'} = &twodigit($min);
} # setup3
# ================================================================
# prettifier for dates
# $val = &twodigit ($field)
sub twodigit { # returns field with leading zero if necessary
    local($x) = $_[0];
    return "$x" if ($x > 9);
    return "0$x";
} # twodigit

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
