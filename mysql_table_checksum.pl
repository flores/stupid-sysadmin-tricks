#!/usr/bin/perl -w

#########################################
#  walks all replicated tables on MySQL
#  master and slave.  Run with no args
#  to see options.
########################################

use strict;

my ($sql,$sth,$slavesum,$mastersum,$table,$type,$db);
my ($each,$line,$flag,$count,$option,$myisam,$opt,$auto);
my (@dbs,@tables,@desc,@checksum,@innodb,@myisam_fail);

die "usage: $0 <options> <master> <slave host>\n\n
	where <option> is mandatory and can be one of\n
	-n -- nagios check\n
	-q -- quiet\n
	-i -- interactive\n
	-a -- auto (yes to all)\n" unless (@ARGV > 2);

my $cli_opt = $ARGV[0];
my $master_host = $ARGV[1];
my $slave_host = $ARGV[2];

my $log = './table_checksum_log';

# we'll use file handles to print HANDLE to tee to stdout or just append log
if ($cli_opt =~ /n|q/)
{
	open (HANDLE, "> $log");
}
elsif ($cli_opt =~ /a|i/)
{
	open (HANDLE, "|tee -a $log");

}

# defining $auto for if statements in interactive mode
if ($cli_opt =~ /n|a/)
{
	$auto = 'y';
}

# weak but fast
else 
{
	$auto ='n';
}


# because populating arrays with DBH doesn't make sense to me :(
# $master_host
my $master = "| mysql -h$master_host -usomeuser -psomepassword";
# $slave_host
my $slave  = "| mysql -h$slave_host -usomeuser -psomepassword";


# grab all databases from slave
@dbs = db_do ("show databases;", $slave);

print HANDLE "I HAZ @dbs";

foreach $db (@dbs)
{
	chomp ($db);
# get rid of databases we know are not replicated
	if ($db =~ /Database|information_schema/)
	{	next;	}

# a simple menu above the formatted output
	print HANDLE "\n\n\nverifying myisam tables on $db!\n";
	print HANDLE "table	         	master checksum	slave checksum coolness?\n";

	@tables = db_do ("use $db; show tables;", $slave);
	foreach $table (@tables)
	{
		chomp ($table);
# get rid of noise
		if ($table =~ /(cookies$|Tables_in_$db|login_tracker|server|year)/)
		{ 	
			next;	
		}

# start
		@desc = db_do ("use $db; show table status like \"$table\";", $slave);

# lets skip innodb tables and stick them into a new array...
		if (grep(/InnoDB/,@desc))
		{
			push (@innodb,$table);
			next;
		}
# ... and lets get to the meat of it with MyISAM
		@checksum = db_do ("use $db; checksum table $table;", $slave);
		foreach $line (@checksum)
		{
			if ($line =~ /(\d+)$/)
			{ 	
				$slavesum = $1; 
			}
		}
		@checksum = db_do ("use $db; checksum table $table;", $master);
		foreach $line (@checksum)
		{
			if ($line =~ /(\d+)$/)
			{
				$mastersum = $1;
			}
		}
		if ($slavesum == $mastersum)
		{ 	
			$flag='OK'; 
		}
		else 
		{ 
			push(@myisam_fail,$table);
			$flag='NOES!';
		}

# make pretty
#		format =
#			@<<<<<<			@<<<<<<		@<<<<<		@<<<<<
#			$table,$mastersum,$slavesum,$flag
#		.
#		write;
		printf HANDLE "%-23s\t", $table;
		printf HANDLE "%12s\t", $mastersum;
		printf HANDLE "%12s\t", $slavesum;
		printf HANDLE "%s\n", $flag;
#		print HANDLE "$table\t$mastersum\t$slavesum\t$flag\n";
	}
# if some myisam tables fail, lets ask if we should check via another method.
	if (@myisam_fail > 0)
	{
		if ($auto !~ /y/)
		{
			print HANDLE "\nsome myisam tables failed checksum.  want to check them via diffs of mysqldump? [y/n] ";
			$opt=<STDIN>;
			chomp ($opt);
		}
		if ($opt or $auto =~ /^y$/)
		{
			foreach $myisam (@myisam_fail)
			{
#				do {
#					print HANDLE "compare $myisam? [y/n] ";
#					$opt=<STDIN>;
#					chomp ($opt);
#					} while ($opt !~ /^y|n$/);
#				if ( $opt or $auto =~ /y/)
#				{ 
					myisam_dump($myisam,$db);
					db_do ("unlock tables;", $master);
					db_do ("unlock tables;", $slave);
#				}
			}
		}
		@myisam_fail=();
	}

# should we do innodb tables?
	if (@innodb < 1)
	{
		next;	
	}
################ pie
#
	print HANDLE "\nInnoDB tables:\n\n@innodb\n";
    if ( $auto !~ /y/ )
    {
		do 
		{
			print HANDLE "\ndump and compare innodb tables? [y/n] ";
			$opt=<STDIN>;
			chomp ($opt);
		} while ( $opt !~ /^y|n$/ );
	}
	if ( $opt or $auto =~ /y/)
	{
		foreach $table (@innodb)
		{	innodb_dump($table,$db); }
	}
	@innodb=();
}

close (HANDLE);

##########################
# subbage
#########################

sub db_do
{
	my ($sql,$handle) = @_;
	my @result = `echo \'$sql\' $handle`;
	return @result;
}

sub myisam_dump
{
	my ($table,$db) = @_;
	print HANDLE "dumping $table from $master_host\n";
	system "mysqldump -h$master_host -usomeuser -psomepassword $db $table --skip-comments -l > $table.$master_host.dump";
	print HANDLE "dumping $table from $slave_host\n";
	system "mysqldump -h$slave_host -usomeuser -psomepassword $db $table --skip-comments -l > $table.$slave_host.dump";
	my @diff= `sdiff  --ignore-tab-expansion -w 100 -Was $table.$slave_host.dump $table.$master_host.dump |egrep -v 'INCREMENT'`;
	if (@diff > 0)
	{
		print HANDLE "comparing $table:\nmaster					slave\n";
		print HANDLE "@diff";
		if ( $auto !~ /y/ )
		{
			print HANDLE "press enter to continue\n";
			<STDIN>;
		}
	}
	if (@diff == 0)
	{
		print HANDLE "$table matches!\n";
		system ("rm -f $table.$master_host.dump $table.$slave_host.dump");
	}

}

sub innodb_dump
{
	my ($table,$db) = @_;
	print HANDLE "dumping $table from $master_host\n";
	system "mysqldump -h$master_host -usomeuser -psomepassword $db $table --skip-comments --single-transaction --skip-opt > $table.$master_host.dump";
	print HANDLE "dumping $table from $slave_host\n";
	system "mysqldump -h$slave_host -usomeuser -psomepassword $db $table --skip-comments --single-transaction --skip-opt > $table.$slave_host.dump";
	my @diff= `sdiff  --ignore-tab-expansion -w 100 -Was $table.$slave_host.dump $table.$master_host.dump |grep -v 'INCREMENT'`;
	if (@diff > 0)
	{
		print HANDLE "comparing $table:\nmaster                  slave\n";
		print HANDLE "@diff";
		if ( $auto !~ /y/)
		{
			print HANDLE "press enter to continue\n";
			<STDIN>;
		}
	}
	if (@diff ==0)
	{
		print HANDLE "$table matches!\n\n";
		system ("rm -f $table.$master_host.dump $table.$slave_host.dump");
	}
}

