#!/usr/bin/perl -w

#open ( HOSTS , "/home/lo/system.map/pings/pinglist" ) || die "Cannot open list of hosts";

for ( $i=1; $i < 17; $i++ ) 
	{
	open ( INET , "< web$i/ifconfig" ) || die "Cannot open web$i ip list"; 
	open ( EDIT_NET , ">>web$i/ip.edit" ) || die "Cannot write $_";
	@inet = <INET>;
	print "\n-----\nweb $i\n-----\n";
	foreach $inet_line ( @inet ) 
		{
		if ( $inet_line =~ /^eth/ )
			{
			$inet_line =~ s/Link.*//g;
			print "\n\n$inet_line";
			}
		if ( $inet_line =~ /inet addr:(\d.+)Bcast:.*/ )
			{
			my $inet=$1;
			print "has inet: $inet\n";
			$inet=`echo $inet | cut -d. -f1,2,3`;
#			open ( ROUTES , "web$i/route" ) || die "Cannot open routing table";
#			@route_line = <VHOSTS>;
			print "\nmatches routes:\n";
			system "ssh web$i route -vn | grep $inet" ;
#			close ( VHOSTS );
			}
		}


	close ( INET );                                   #close jankness
	close ( EDIT_NET );
	}

@inet=();

