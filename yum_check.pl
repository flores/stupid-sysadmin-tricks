#!/usr/bin/perl 
use strict;

################################
#  Clears yum, checks if it    #
#  can grab info.  If error    #
#  exits 2 for Nagios. -- clo  #
################################

system ("/usr/bin/yum clean all 2&>1 /dev/null");
my @yum=`/usr/bin/yum info 2&>1 /dev/null`;
my $yum_stat=$?;
my ($return,$status);

if ($yum_stat==0)
{ $return='0'; $status='OK'; }
else
{ $return='2'; $status="CRITICAL: yum info exited $yum_stat"; }

print "$status";
exit $return;
