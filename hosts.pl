#!/usr/bin/perl -w

##########################################################
# Walks pre-populated files to match respective        	 #
# httpd.conf to vhosts.                                  #
# I realize my perl is jank.  Not for production.        #
# -- Carlo  Flores                                       #
##########################################################

#open ( HOSTS , "/home/lo/system.map/pings/pinglist" ) || die "Cannot open list of hosts";

for ( $i=1; $i < 17; $i++ ) 
	{
	open ( INET , "/home/lo/system.map/web$i/ifconfig" ) || die "Cannot open web$i ip list"; 
	open ( EDIT_NET , ">>/home/lo/system.map/web$i/ip.edit" ) || die "Cannot write $_";
	@inet = <INET>;
	print "\n-----\nweb $i\n-----\n";
	foreach $inet_line ( @inet ) 
		{
		if ( $inet_line =~ /^eth/ )
			{
			$inet_line =~ s/Link.*//g;
			print $inet_line;
			}
		if ( $inet_line =~ /inet addr:(\d.+)Bcast:.*/ )
			{
			my $inet=$1;
			print "$inet\n";
			open ( VHOSTS , "/home/lo/system.map/pings/ping_list" ) || die "Cannot open pinglist";
			@vhost_line = <VHOSTS>;
			system "grep $inet /home/lo/system.map/pings/ping_list";
			close ( VHOSTS );
			}
		}


	close ( INET );                                   #close jankness
	close ( EDIT_NET );
	}

@inet=();

