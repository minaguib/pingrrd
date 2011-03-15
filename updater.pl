#!/usr/bin/env perl

use strict;
use Net::Ping;
use Time::HiRes qw(usleep);
use RRD::Simple ();

#$RRD::Simple::DEBUG=1;

$|=1;
my $PINGER;
my $IP;
my $RRD = RRD::Simple->new(file => "data/ping.rrd");


sub load_pinginfo() {

	local(*IPFILE);
	open(IPFILE, "IP") || die("No open");
	$IP = <IPFILE>;
	close(IPFILE);
	chomp($IP);

	if ($PINGER) {
		$PINGER->close();
	}

	$PINGER = Net::Ping->new("icmp");
	$PINGER->hires(1);

}

sub main() {
	my $i=0;
	while(1) {
		if (!$i || ($i % 6) == 0) { load_pinginfo() }
		print scalar(localtime) . " : ";
		my ($num_sent, $num_received, $num_lost, $rtt) = run_test();
		print " : SENT [$num_sent] RECEIVED [$num_received] LOST [$num_lost] AVG RTT [$rtt]\n";
		$RRD->update(
			sent => $num_sent,
			received => $num_received,
			lost => $num_lost,
			rtt => $rtt
		);
		$i++;
	}
}

sub run_test() {

	my $timeout = 10;
	my $num_sent = 0;
	my $total_rtt = 0;
	my $num_lost = 0;
	my $num_received = 0;

	for (my $i = 1; $i <= 10; $i++) {
		my ($ret, $duration, $ip) = $PINGER->ping($IP, 1);
		$num_sent++;
		if ($ret) {
			print(".");
			#printf("$host [ip: $ip] is alive (packet return time: %.2f ms)\n", 1000 * $duration) if $ret;
			$num_received++;
			$total_rtt += $duration;
		}
		else {
			print("x");
			#printf("Lost packet\n");
			$num_lost++;
		}
		usleep((1.0 - $duration) * 1_000_000.0) if ($duration < 1.0);
	}

	return(
		$num_sent,
		$num_received,
		$num_lost,
		($num_received > 0) ? ($total_rtt / $num_received * 1000) : 0
	);

}

main();
