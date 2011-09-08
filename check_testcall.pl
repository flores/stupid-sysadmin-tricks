#!/usr/bin/perl

# checks if asterisk can make a call

my $number = shift || "2135551212";

use Sys::Hostname;
eval("use Time::ParseDate; \$Time::ParseDate::VERSION") || error("Can't use Time::ParseDate");

my $TO = 'emerg@somehost';

my $LASTCHECK = 20;
my $FROM = "proxy\@somehost.com";
my $CC = "";
my $LOG = "/tmp/some.log";

open(LOG, "<$LOG") || error("Can't read log file $LOG");

my @time = localtime();
my $now = time();
my $lastlog;

while (<LOG>)
{
	if (/$number/ && !/1st attempt/)
	{
		chomp($lastlog = $_);
	}
}
close(LOG);

if ($lastlog =~ /(\S+\s+\S+\s+\S+\s+(\d+):(\d+):\d+\s+\S+)/)
{
	my ($date, $hour, $min) = ($1, $2, $3);

	my $lastcheck = parsedate($date);

	# make sure this entry is within $LASTCHECK minutes of now
	if ($now - $lastcheck > $LASTCHECK * 60 && $now > 0 && $lastcheck > 0)
	{
		error("No status checks in last $LASTCHECK minutes ($now - $lastcheck)");
	}

}
elsif ($lastlog)
{
	error("Can't interpret date from $lastlog ($number)");
}
else
{
	error("No logs for $number");
}

# success
exit;



sub error
{
	open LOG;
	print LOG "Error: " . localtime() . ": $_[0]\n";
	close(LOG);

	my $time = localtime;
	my $host = hostname;

	my $num = $number;
	$num =~ s/\|.*$//;
	$num =~ s/^(\d{3})(\d{3})(\d{4})/$1-$2-$3/;

	open(SM, "|/usr/sbin/sendmail -t");
	print SM << "EOF";
From: $FROM
To: $TO
Cc: $CC
Subject: $num POSSIBLY DOWN!

$num POSSIBLY DOWN
$time: $_[0] ($host:$0)

EOF
	close(SM);

	exit;
}
