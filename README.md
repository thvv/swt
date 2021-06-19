# swt
Super Webtrax  - Web log analysis report
version 14, 2021-02-18

See https://multicians.org/thvv/swt.html

PREREQUISITES
- Perl5
- MSQL 4.1 or better
- ability to use Unix commands

INSTALLATION INSTRUCTIONS

Ensure that MySQL is installed.  Set up a database, username,
and password. Create $HOME/.my.cnf with that info.

Switch to the "master" branch and click "Code" to clone the repo to 
a directory install-swt.
Install install-swt/expandfile in your $PATH.
Install expandfile.pm, readbinsql.pm, readbinxml.pm in your $PERL5LIB.
Install CPAN modules LWP::Simple, Term::ANSIColor, DBI, DBD::mysql, XML::LibXML, XML::Simple in your $PERL5LIB

Run the configure script by doing
-  cd install-swt
-  ./configure

It will ask for the following:
- where to install the code
- where to write temporary data
- name of the SQL database
- SQL database server domain address
- SQL database username
- SQL database password
- Report title
- directory where the output files will be moved
- directory where config file is kept
- Your domain name
- path to mysql
- path to mysqldump
- daily log file or running log file
- do reverse DNS?
- do GEOIP?
- where ISP puts log file
- where to put bad logfiles
- where to put processed logfiles

It will test that software is installed and that the database is working.
It will then build configuration files in swt-install.
Rerun 'configure' to update settings.

When configuration is done and satisfactory, do
  ./install

It will move swt, *.htmt, *.htmi, *.sql, *.sh to the program dir
It will move swtconfig.htmi to the config file dir
It will move mys, mysqlload and mysqldumpcum to the program dir
It will move all the gifs (one pixel stuff) to the report dir
It will move all the Java class files to the report dir
It will copy swtstyle.css and swt.js to the report dir.

If this is a new install it will ask whether to init the database.

The installer generates a cron job to run Super Webtrax every night
and to move the output files to your web statistics display
directory.  This job may require hand editing.  Because jobs started by
cron do not execute your shell startup, you must take special steps to
ensure that your $PATH, $PERL5LIB, and other shell variables are
correctly set.

If you are doing GeoIP processing, download GeoLite2-City.mmdb from
http://www.maxmind.com/ (need a free license) and install it in ~/lib,
Ensure that GeoIP2::Database::Reader is installed on the Perl path.

Tailor swt-user.sql as needed.


MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
