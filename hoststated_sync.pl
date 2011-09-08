#!/usr/bin/perl -w

use strict;
use List::MoreUtils qw(uniq);

#declare backup loadblancer.  must be reachable.
my $targethost='nlb1-lax1';

my @hoststated = uniq `awk '\$1 ~ /host/ {print \$3" "\$4}' host`;

my ($line,$host,$status);

foreach $line (@hoststated)
{
	if ($line =~ /disabled/)
	{
		$line =~ /^(.*?)\s(.*)d$/;
		print "ssh $targethost hoststatectl host $2 $1\n";
	}
	else
	{
		$line =~ /^(.*?)\s/;
		print "ssh $targethost hoststatectl host enable $1\n";
	}
}
