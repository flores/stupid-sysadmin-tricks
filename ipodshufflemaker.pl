#!/usr/bin/perl -w

#stick 5000 random songs into ~/shuffle.

use strict;

my ($source,$target,$count,$num)=('~/tunage','~/shuffle',0,0);

# its faster to regex this list in perl than -not -regexp in find.
my @list=`find $source`;
chomp (@list);
my $total=$#list;

# testing 
#my ($bogus,$unrand,$check)=(0,0,0);

while ($count < 5000)
{
	$num=`echo \$RANDOM`;
	chomp ($num);
#	if ($num==$check)
#	{ $unrand++; }
	if ( ($num < $total) && ($list[$num] !~ /(jpg|png|gif|bmp|txt|m3u|pls|\/)$/ ) )
	{
#		print "$list[$num]\n";
		system("cp \"".$list[$num]."\" ~lo/shuffle");
		$count++;
	}
#	else { $bogus++; }
#	$check=$num;
}
#print "count:$count bogus: $bogus not random: $unrand\n";
