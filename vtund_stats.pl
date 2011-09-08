#!/usr/bin/perl -w
use strict;

my $host;	
my $proxy1='down';
my $proxy2='down';
my @hosts_list=`cat /etc/hosts | grep someidentifierforhosts | awk {'print \$2'};`;
my @proxy1_list=`ssh proxy1 "ls /usr/local/var/lock/vtund | sed -e 's/-2//'"`;
my @proxy2_list=`ssh proxy2 "ls /usr/local/var/lock/vtund"`;
chomp (@hosts_list, @proxy1_list, @proxy2_list);
my @status=();
my @corner=();
my $server;
my $proxy1_count='0';
my $proxy2_count='0';

foreach $host ( @hosts_list )
{
	if ( grep ( /$host/, @proxy1_list ) )
	{ 
		$proxy1='up';
		$proxy1_count++;
	}
	if ( grep ( /$host/, @proxy2_list ) )
	{
		$proxy2='up';
		$proxy2_count++;
	}
	push ( @status, "$host	$proxy1	$proxy2" );
	$proxy1='down';
	$proxy2='down';
}
foreach $server ( @status )
{
	print "$server\n";
	if ( $server =~ /up/ && $server =~ /down/ )
	{
		push ( @corner, $server );
	}
}
print "---------------------
Server  	Proxy1  Proxy2
---------------------\n
proxy1 connection percentage : " . $proxy1_count / $#hosts_list * 100 . " %\n
proxy2 connection percentage : " . $proxy2_count / $#hosts_list * 100 . " %\n
percentage of servers 
    connected to one tunnel  :  " . $#corner / $#hosts_list * 100 ." %\n
---------------------\n";

print "\nSee servers with only one tunnel? [y/n] ";
my $input = <STDIN>;
chomp $input;

if ( $input eq 'y' )
{
	print "\n\n";
	foreach $server ( @corner )
	{
		print "$server\n";
	}
}
else 
{
	exit 255;
}

