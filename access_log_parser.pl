#!/usr/bin/perl

my %users=();

@list = `cat $ARGV[0]`;

my ($line,$username,$url,$status,$message);
#10.214.18.175 - sandrabergasa@gmail.com [08/Jul/2010:08:42:18 +0000] "GET /user/84f1e289f89971f/slides?closed=false&page=1&eager=user,reader_list,reply_list,preferences&target_url_hash=929dfcd3a7c81c3d9b11fcf9fb04fd864f6874a6180080b9acad2d3b13a91c63 HTTP/1.1" 200 44 "-" "Mozilla/5.0 (Windows; U; Windows NT 6.0; es-ES; rv:1.9.2.6) Gecko/20100625 Firefox/3.0.7;MEGAUPLOAD 1.0 GTB7.0 ( .NET CLR 3.5.30729) FBSMTWB"
#10.214.18.175 - nakllorente@gmail.com [08/Jul/2010:08:42:20 +0000] "GET /user/9fb278b24974718/slides?closed=false&page=1&eager=user,reader_list,reply_list,preferences&target_url_hash=3832109a4556fa4640b0a04afebd730139cf7291f0cd83868f75e61997a669d3 HTTP/1.1" 200 44 "-" "Mozilla/5.0 (Windows; U; Windows NT 6.1; es-ES; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6 (.NET CLR 3.5.30729)"
#10.214.18.175 - - [08/Jul/2010:08:42:22 +0000] "GET /health_check HTTP/1.1" 200 12 "-" "ELB-HealthChecker/1.0"

my ($count,$unknown,,$count_target_url,$count_feed,$count_contacts,$count_api_nocookie,$count_api,$count_static)=0;
my ($time_overall,$time_this,$time_target_url,$time_feed,$time_contacts,$time_api_nocookie,$time_api,$time_static)=0;

my ($glass_xpi,$update,$glass_safari,$glass_crx,$chrome_update,$safari_update)=0;

foreach $line (@list)
{
# LB and monitoring checks
	if ($line =~ /ELB-HealthChecker/)
	{ next; }
	if ($line =~ /Cloudkick.*(\d+\.\d+)$/)
	{
		$time_ck=$1;
		$time_ck*=1000;
		next;
	}	
# grab the username from logs, stick it in a hash we can play with later
	if ($line =~ /^(.*)?\s-(.+)?\s\[.+(?:GET|POST)\s(.+)HTTP.*(\d+\.\d+)$/)
	{
		$username = $2;
		$content = $3;
		$time_this= $4;
		$time_this*=1000;
		$time_all+=$time_this;
		$count++;
		
		if (defined $users{$username})
		{ $users{$username} = $users{$username}++; }
		else
		{ $users{$username} = 0; }
# counting glass.xpi and update.rdf calls
		if ($content=~/glass.xpi/)
		{ $glass_xpi++; }
		elsif ($content=~/update.rdf/)
		{ $update++; }
		elsif ($content=~/glass.crx/)
		{ $glass_crx++; }
		elsif ($content=~/update.xml/)
		{ $chrome_update++; }
		elsif ($content=~/glass.safariextz/)
		{ $glass_safari++; }
		elsif ($content=~/Update.plist/)
		{ $safari_update++; }
# counting pieces of our product
		elsif ($content=~/feed/)
		{ $count_feed++; $time_feed+=$time_this; }
		elsif ($content=~/target_url_hash/)
		{ $count_target_url++; $time_target_url+=$time_this; }
		elsif ($content=~/contacts/i)
		{ $count_contacts++; $time_contacts+=$time_this; }
# I am curious about what happens when there's no cookie
		elsif ($content=~/api\s/i)
		{ $count_api_nocookie++; $time_api_nocookie+=$time_this; }
		elsif ($content=~/api\?/i)
		{ $count_api++; $time_api+=$time_this; }
# if it hasn't matched already and doesn't pass parameters, we're assuming it is static
		elsif ($count!~/\?/)
		{ $count_static++; $time_static+=$time_this; }
		
# ... and we could just count the values of every entry in that hash, but this is faster.
	}
	else
	{	$unknown++; }
}	

# if nobody has connected, let's trigger a warning
if ($count == 0)
{	
	$status = 'warning';
	$message = 'no new http connections on this host';
	exit;
}
else
{
	$status = 'ok';
	$message = 'ok';
}


$time_all/=$count;
$time_feed/=$count_feed if $count_feed != 0;
$time_target_url/=$count_target_url if $count_target_url != 0;
$time_contacts/=$count_contacts if $count_contacts != 0;
$time_api/=$count_api if $count_api != 0;
$time_api_nocookies/=$count_api_nocookies if $count_api_nocookies != 0;
$time_static/=$count_static if $count_static != 0;

# requests/sec -- 5 minutes
my $requests_sec=$count/(300);

# all requests to dis
my $count_dis=($count_feed + $count_target_url + $count_contacts + $count_api + $count_api_nocookies);

#system ("cp /var/log/nginx/access.log /tmp/access.log.old");
#my ($glass_xpi,$update,$glass_safari,$glass_crx,$chrome_update,$safari_update)=0;

print "status $status $message
metric hits int $count
metric hits_static int $count_static
metric hits_dis int $count_dis
metric hits_feed int $count_feed
metric hits_api int $count_api
metric hits_api_nocookies int $count_api_nocookies
metric hits_contacts int $count_contacts
metric hits_target_url int $count_target_url
metric req_sec float int $requests_sec
metric unique_users int " . keys(%users) . "
metric firefox_downloads int $glass_xpi
metric firefox_update_checks int $update
metric chrome_downloads	int $glass_crx
metric chrome_update_checks int $chrome_update
metric safari_downloads int $glass_safari
metric safari_update_checks int $safari_update
metric unknown_users int $unknown
metric nginx_time_ckchecks float $time_ck
metric nginx_time_overall float $time_all
metric time_feed float $time_feed
metric time_target_url float $time_target_url
metric time_contacts float $time_contacts
metric time_api float $time_api
metric time_api_no_cookies float $time_api_nocookies
metric time_static float $time_static

";

