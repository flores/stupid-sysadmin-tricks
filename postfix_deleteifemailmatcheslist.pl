#!/usr/bin/perl -w

die "usage $0 <path to email list>\n" unless @ARGV;

my $file=$ARGV[0];

my @queue=`postqueue -p |grep -v ^- |awk  'BEGIN{RS="\\n\\n"} ; {print \$1"\t"\$NF}'`;

my @list_users=`cat $file`;

foreach my $line (@queue)
{
	$line=~/^(.+)?\t(.+)$/;
	$queueid = $1;
	$user = $2;
	if (grep(/$user/,@list_users))
	{ 
		system ("postsuper -d $queueid"); 
		print "I am deleting $user email\n";
	}
}

