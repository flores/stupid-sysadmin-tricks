#!/usr/bin/perl 

########################################################
#  Checks for any high cpu processes or low available  #
#  RAM.  Obtains strace of that process, logs, kills   #
#  if httpd child, then pages. Because that's how      #
#  we roll.  Also checks if apache is running and      #
#  low RAM                                             #
#                -- lo                              #
########################################################

use strict;

my $host=`hostname`;
my $pidfile='/var/log/http_check.pid';
my $perlpid=`cat $pidfile`;
chomp ($perlpid,$host);

if ($perlpid > 0)
{
	system "kill -9 $perlpid";
	system "echo 0 > $pidfile";
	exit 255;
}
else 
{
	system "/bin/echo $$ > $pidfile";
}

 
# log file to store high cpu processes
my $cpu_log='/var/log/high_cpu_processes';

# log file to store straces
my $strace="/var/log/strace.\`date +%y%b%d\`";

my $proc;
my @stat=`ps aux`;
my $mem=`cat /proc/meminfo | grep -i memfree`;
my $time=localtime();
my ($cpu, $pid);
#my @maillog=();
chomp (@stat,$mem);

$mem =~ /(\d+)/;
my $memfree = "$1";
if ( $memfree < 10000 )
{
	system "/usr/local/apache/bin/apachectl stop && sleep 5 && /usr/local/apache/bin/apachectl start";
	open (APACHE, ">> $cpu_log");
	print APACHE "$time $memfree KB of RAM available.  Restarted apache\n.";
	close (APACHE);
}

foreach $proc ( @stat )
{
	if ( $proc =~ /^\w+?\s+?(\d+)\s+?(\d+\b.\d+)/ ) 
	{
		$pid="$1";
		$cpu="$2";
		# CPU threshold
		if ( $cpu > 75 ) 
		{
			open ( LOG, ">> $cpu_log");
			if ( $proc =~ /httpd/i )
			{
#				push (@maillog,"proc");
				print LOG "$time : $proc\n";
				if ( $cpu > 90 )
				{
					eval 
					{			 
						local $SIG{ALRM} = sub {die "alarm\n"};
						alarm 10;
						system "/usr/bin/strace -p $pid -o $strace\.pid$pid";
						alarm 0;
					};
#					push (@maillog,"10 second strace captured in $strace\.pid$pid");
					system "kill -9 $pid";
#					push (@maillog, "$host witnessed impending doom.  Killed $pid");
					print LOG "killed $time : $proc\n";
#					if ($memfree < 10000)
#					{
#							system "/usr/local/apache/bin/apachectl restart";					        	print MAIL "$host had $memfree free RAM remaining.  HUP'd Apache.\n"
#					}
				}
			}
			
			if ( ($proc =~ /neo_call|pull_queue|updatedb|ifconfig|swap|sync_updates/) )
			{
				print LOG "$time highcpu: $proc\n"; 
			}

			else
			{
				if ($cpu > 75)
				{
					eval
					{
						local $SIG{ALRM} = sub {die "alarm\n"};
						alarm 10;
						system "/usr/bin/strace -p $pid -o $strace\.pid$pid";
						alarm 0;
					};
#					push (@maillog, "10 second strace captured in $strace\.pid$pid for: $proc");
					print LOG "$time : $proc\n";
				}
			}
			close ( LOG );
		}
	}
}

@stat=();

# instead just writing to log
#if (@maillog)
#{
#	open (MAIL, "|/bin/mail -s \"problem processes on $host\" systeam\@somehost.com" );
#	foreach my $line (@maillog)
#	{
#		print MAIL "$line\n";
#	}
#	close (MAIL);
#}

# Let's do some sanity checks to see if everything is running as we expect

my $http_check=`ps ax|egrep "apache.*httpd"|grep -v "grep"|head -1`;
chomp ($http_check);
if ( $http_check !~ /apache.*httpd/ )
{
	print "NO APACHE";
	system "/usr/local/apache/bin/apachectl stop && sleep 10 && /usr/local/apache/bin/apachectl start";
	open (APACHE, ">> $cpu_log");
	print APACHE "$time: apache was not running.  Started\n";
	close (APACHE);
}

#my $lighttp_check=`ps -e |grep lighttpd|grep -v "grep"|head -1`;
#chomp ($lighttp_check);
# Let's see if we can connect over http

system "wget http://$host.somehost.com -o ~/http_wget";
my @https=`cat ~/http_wget`;
chomp (@https);
foreach my $line (@https)
{
	if ( $line=~/HTTP request sent.*200 OK/ )
	{
		system "echo 0 > $pidfile";
		exit 255; # we're chill
	}
	if ( $line=~/fail|refused/i)
	{
		print "http failed\n";
		open (LOG, ">>/var/log/httpd_restarts");
		print LOG "I restarted apache because:";
		foreach my $logline (@https)
		{
			print LOG "$logline\n";
		}
		close (LOG);
		system "/usr/local/apache/bin/apachectl stop && sleep 10 && /usr/local/apache/bin/apachectl start";
	}
	else 
	{
		next;
	}
}
		
system "echo 0 > $pidfile";

