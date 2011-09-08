#!/usr/bin/perl -w

# emails any user and sysadmin for home dirs using > 100MB. - carlo

use strict;
my $host=`hostname`;
my @users=`cat /etc/passwd`;
chomp (@users,$host);
my ($user,$usage);

# threshold in megabytes
my $thresh='100';

foreach my $line (@users)
{
    $line=~/^(\w+)\:.+?(\/.+?):/;
	$user="$1";
	$usage="$2";
	print "user is $user and homedir is $usage\n";
#	$usage=`du -hsm "/home/$user"`;
#    chomp ($usage);
#    $usage=~/(\d+).*\/home\/(\w.*)/;
#    $usage="$1";
#    $user="$2";
#    if ($usage > $thresh)
#    {
#		print "$user over $thresh";
#        system "echo \"Hi $user.  Please free space on your home directory on $host.  Our limit is $thresh M. You are using $usage M.\" | /bin/mail -s \"disk usage on $host\" $user\@somehost.com,carlo\@somehost.com";
#    }
}
