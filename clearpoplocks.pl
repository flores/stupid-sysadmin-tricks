#!/usr/bin/perl

# backs up and deletes .pop files older than
# 30 minutes on mailserver -- lo

use strict;
use Date::Manip;

my $log="/var/log/pop.log";

# my @pops=`cat mailtest`;
# comment above and uncomment below to make live.
my @pops=`ls -la /var/spool/mail/.*pop 2> /dev/null`;
chomp (@pops);

# just exit if there are no files
if (@pops <1)
{ exit 0; }

# date stuff
my $now=&ParseDate("today");
my @fields=();
my ($file,$time,$name,$diff);
my $year=`date +%Y`;
chomp ($year);

foreach $file (@pops)
{
#splitting that ls to grab file name and date.
	@fields=split(/\s+/,$file);
	$name=$fields[8];
	chomp ($name);
	$time="$year $fields[5] $fields[6] $fields[7]";
	$diff=&DateCalc(&ParseDate($time),$now);
#date calc retuns minutes difference in the sixth colon-delimited field.	
	$diff=~/^(.*?:){5}(.*?):/;
	if ($2 > 30)
	{
#comment out print and adjust system calls to make live.
		system ("cp $name $name.backup; rm -f $name");
#log event
		open (LOG,">>$log");
		print LOG "$now: $name was $2 minutes old.  backed up to $name.backup and deleted\n";
		close (LOG);
	}
	@fields=();
}
@pops=();
