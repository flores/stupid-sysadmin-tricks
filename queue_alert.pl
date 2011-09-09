#! /usr/bin/perl -w

use strict;

@queue=`asterisk -rx 'show queue NeoSupport'`;
my $line;
my @li_ext=();

foreach $line (@queue)
{
	if ($line=~/^\s+?Local\/\#40\d\d(\d+?)\@neoagent/)
	{
	push (
