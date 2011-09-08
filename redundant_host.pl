#!/usr/bin/perl -w	

use strict;

$/="relay";

my @hosts=`cat summary`;
my ($active);
my @set=();

foreach $active (@hosts)
{
	@set=split(/\n/, $active);
}

foreach my $line (@set)
{
	print $line;
}
