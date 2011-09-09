#!/usr/bin/perl -w

use strict;

my $server=$ARGV[0];
my @log=`cat access.log.$server`;

my $line;
my $cpa=0;
my $cpu=0;
my $stat=0;
my $count=0;

foreach $line (@log)
{
	$count++;
	if ($line =~ /cpa.cgi/)
	{ $cpa++; }
	elsif ($line =~ /cpu.cgi/)
	{ $cpu++; }
	elsif ($line =~ /stats/)
	{ $stats++; }
	else
	{ next; }
}

print "count:$count cpu:$cpu cpa:$cpa stat:$stat";
