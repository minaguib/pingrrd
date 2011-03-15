PINGRRD
---------------------------------

A simple tool to ping an IP address, store the result in an RRD file, and
easily generate graphs from the stored data.

This is useful to, for example, keep an eye on your latency to your ISP's
gateway, VPN tunnel, or other single important endpoint, without investing too
much time setting up a heavier system such as cacti.

Requirements
---------------------------------

 * RRDtool - http://www.mrtg.org/rrdtool/
 * GNU Make - http://www.gnu.org/software/make/
 * Perl - http://www.perl.org/
 * Perl modules:
 	* perl -MCPAN -e 'install Net::Ping'
	* perl -MCPAN -e 'install RRD::Simple'
 * Optional - a web server to easily see the produced graphs
 	* Set your document root to the ./graphs subdirectory

Usage
---------------------------------
 * Create or edit file "IP", put the IP address to monitor in it
 * sudo ./updater.pl
 * run "make -C /path/to/pingrrd" whenever you want the graphs re-generated
 	* Can put it in cron every minute or so

Todo
---------------------------------
 * Add support for pinging multiple endpoints
 * Replace Net::Ping with something that doesn't require sudo
