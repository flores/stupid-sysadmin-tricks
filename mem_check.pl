#!/usr/bin/perl -w

use strict;

my $host=`hostname`;
my @free=`free| grep -v total`;
chomp ($host,@free);
my ($line,$swap,$mem);
foreach $line (@free)
{
	$line=~/^(\w+)\:.*?\d+\s+(\d+?)\s+(\d+?)/;
	if ($1=~'Mem')
	{
		$mem==$3;
	}
	if ($1=~'Swap')
	{
		$swap==$2;
	}
} 

print "Memory free: $mem\nSwap used: $swap\n";

#if ($mem > 0)
#{
#	print "
#	open (MAIL, "|/bin/mail -s "$host is swapping" emerg_prod@somehost.com
