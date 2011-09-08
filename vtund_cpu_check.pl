#!/usr/bin/perl -w

use strict;

my $host=`hostname`;
my $proc;
my @stat=`ps aux`;
my $time=localtime();

foreach $proc ( @stat )
{
	if ( $proc =~ /^\w+\s+(\d+)\s+(\d+\b.\d+)/ )
	{
# CPU threshold
		if ( $2 > 90 )
		{
			open ( LOG, ">>/var/log/high_cpu_processes.log");
			open ( MAIL, "|/bin/mail -s \"high cpu usage on $host\" systemalerts\@someplace.com" );
# its ok to restart this process
			if ( $proc =~ /vtund/i )
			{
				system "kill $1 && /etc/init.d/vtund restart";
				print MAIL "Killed: $proc\n";
				print LOG "$time killed: $proc\n";
			}
# processes that may run periodically
			elsif ( $proc =~ /updatedb/ || $proc =~ /ifconfig/ )
			{
				print LOG "$time highcpu: $proc\n"; 
 
			}
			else
			{
				print MAIL "High CPU: $proc\n";
			}
			close ( MAIL );
			close ( LOG );
		}
	}
}

@stat=();
		
