#!/usr/bin/env perl

# expects access log in ~/logs
# walks it, looks for non 40x GETs with no auth, then curls them from localhost
# the idea is that a successful production request yesterday should not fail today
# REALLY GROSS AND INITITAL CHECKIN.  sorry, yo.

# grab all relevant urls and stick them into a hash

my %urlset = {};

my @log = `cat ~/logs/access.log`;

my ($host, $url) = '';

my $exitstatus = 0;

# gross hack for initial key after fucking up the hash
my $i = -1;

foreach my $line (@log) {
  @record=split(" ", $line);

  #skip 40x, non-GETs, and shit that requires auth
  next if ( $record[6] =~ /NONE\/40/ || $record[8] ne "GET" || $record[$#record] !~ /AUTH_NONE/ );

  #regex out the host and uri, stick them into the urlset hash
  $record[9] =~ /http:\/\/(.+?)\/(.+)$/;
  $host = $1;
  $uri = $2;

  next unless ( $host && $uri );
 
  #grab only http status
  $record[6] =~ /(\d+)$/;
  $status = $1;

  $i++;
  $urlset{$i} = {
    host => $host,
    uri  => $uri,
    status_now => undef,
    status_sample => $status,
  };
}

# lets not forkbomb
use Parallel::ForkManager;
my $pm = new Parallel::ForkManager(50);

# lets prep a table if we have any failures
use Text::Table;
my $tb = Text::Table->new(
  "url", "status\nproduction yesterday", "status\nstaging today"
);

for ( my $x = 0; $x < keys ( %urlset ); $x++ ) { 
  $pm->start and next;
    $url = "$urlset{$x}{'host'}/$urlset{$x}{'uri'}";

    # curl that shit, record only the http return code
    $urlset{$x}{'status_now'}=`curl -m 1 -s -H "Host:$urlset{$x}{'host'}" -w "%{http_code}" \'localhost:8820/$urlset{$x}{'uri'}\' -o /dev/null`;
    
    if ( ( $urlset{$x}{'status_now'} != $urlset{$x}{'status_sample'} ) && 
      ( $urlset{$x}{'status_now'} !~ /^(40|0|3)/ && $urlset{$x}{'status_sample'} =~ /^2/ ) ){
        
      # push this guy to our table.  ensure we exit non-0
      print "$url went from $urlset{$x}{'status_sample'} to $urlset{$x}{'status_now'}\n"; 
      $tb -> load (
        [ $url, $urlset{$x}{'status_sample'}, $urlset{$x}{'status_now'} ],
      );
      $exitstatus = 1;
    }      
  $pm->finish;
}

if ($exitstatus != 0) {
  print $tb;
}

exit $exitstatus;
