#!/usr/bin/perl -w

use strict;

#die "usage: $0 <mysql_server_hostname>" unless (@ARGV > 0);

#my $server=@ARGV;
#chomp $server;
#my @users=`ssh $server "echo \"select user,host from mysql.user;\" | /usr/bin/mysql"`;
my @users=`echo "select user,host from mysql.user" | /usr/bin/mysql`;
chomp @users;
my ($line, $user, $ip);

foreach $line (@users)
{
	$line=~/^(\w+)\s+?(.+)/;
	$user="$1";
	$ip="$2";
	#print "user $user ip $ip \n";
	system "echo \"show grants for \'$user\'@\'$ip\';\" | /usr/bin/mysql";
}
