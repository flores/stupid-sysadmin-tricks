#!/usr/bin/perl -w

#########################################
#  walks all replicated tables on MySQL
#  master and slave.  Run with no args
#  to see options.
########################################

use strict;

my ($sql,$sth,$slavesum,$mastersum,$table,$type,$db);
my ($each,$line,$flag,$count,$option,$myisam,$opt,$auto);
my (@dbs,@tables,@desc,@checksum,@innodb,@myisam_fail);

die "usage: $0 <options> <master> <slave host>\n\n
	where <option> is mandatory and can be one of\n
	-n -- nagios check\n
	-q -- quiet\n
	-i -- interactive\n
	-a -- auto (yes to all)\n" unless (@ARGV > 2);

my $cli_opt = $ARGV[0];
my $master_host = $ARGV[1];
my $slave_host = $ARGV[2];

my $log = './table_checksum_log';

# we'll use file handles to print HANDLE to tee to stdout or just append log
if ($cli_opt =~ /n|q/)
{
	open (HANDLE, "> $log");
}
elsif ($cli_opt =~ /a|i/)
{
	open (HANDLE, "|tee -a $log");

}

# defining $auto for if statements in interactive mode
if ($cli_opt =~ /n|a/)
{
	$auto = 'y';
}

# weak but fast
else 
{
	$auto ='n';
}

