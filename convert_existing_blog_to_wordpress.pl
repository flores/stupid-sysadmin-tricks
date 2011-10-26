#!/usr/bin/env perl 

##########
#
# migrates some blog with something like 
# title, published_at, permalink, body 
# in a sql table called posts 
# into an xml we can import into wordpress.
#
# also makes htaccess redirects from the newsite 
# to the new one 
#
# (because we can't just redirect match or a regex
# or something, because, say, we also need date of the 
# post in the url)
#
##########

use DBI;


## options

# this can be the same site, of course
my ( $newsite, $oldsite ) = ( "", ""  );

my ( $db_host, $db, $db_user, $db_pass ) = ( "", "", "", "" );

my $xmlfile = "";
my $htaccessfile = "";

## 



open (XML, "> $xmlfile");

print XML "<?xml version=\"1.0\"?>\n";
print XML '
<rss version="2.0"
        xmlns:excerpt="http://wordpress.org/export/1.1/excerpt/"
        xmlns:content="http://purl.org/rss/1.0/modules/content/"
        xmlns:wfw="http://wellformedweb.org/CommentAPI/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:wp="http://wordpress.org/export/1.1/"
>
';

print XML "<channel>
	<title>Somecompany</title>
	<link>$newsite</link>
	<description>Changing the World One App at a Time</description>
	<pubDate>Wed, 05 Oct 2011 19:59:13 +0000</pubDate>
	<language>en</language>
	<wp:wxr_version>1.1</wp:wxr_version>
	<wp:base_site_url>http://$newsite</wp:base_site_url>
	<wp:base_blog_url>http://$newsite</wp:base_blog_url>
	<wp:author>
		<wp:author_id>1</wp:author_id>
		<wp:author_login>admin</wp:author_login>
		<wp:author_email>blogadmin@$newsite</wp:author_email>
		<wp:author_display_name><![CDATA[SomeSite]]></wp:author_display_name>
		<wp:author_first_name>somename></wp:author_first_name>
		<wp:author_last_name>somedata</wp:author_last_name>
	</wp:author>
	<generator>http://wordpress.org/?v=3.2.1</generator>\n";


open (HTACCESS, ">> $htaccessfile");

my $dbh = DBI->connect ("DBI:mysql:$db:$db_host", "$db_user", "$db_pass",
	{ RaiseError => 1, PrintError => 0});

my $sth = $dbh->prepare ("SELECT title,published_at,permalink,body FROM posts");
$sth->execute ();

# because marketing wants to start with some post count
my $post_id = 327;

while (my ($title, $published_at, $permalink, $body) = $sth->fetchrow_array ())
{
# because marketing wants date as part of the link
#       2010-03-11 22:32:00
	my $published_at =~ /^(\d+)-(\d+)-(\d+)\s(.+)$/;
	my $year = $1;
	my $month = $2;
	my $day = $3;
	my $time = $4;
	print XML "\t<item>\n";
	print XML "\t\t<title>$title</title>\n";
	print XML "\t\t<link>http://$newsite/$year/$month/$day/$permalink</link>\n";
	print XML "\t\t<pubDate>$published_at</pubDate>\n";
	print XML "\t\t<post_date>$published_at</post_date>\n";
	print XML "\t\t<post_id>$post_id</post_id>\n";
	print XML "\t\t<guid isPermaLink='false'>http://$newsite/?p=$post_id</guid>\n";
	print XML "\t\t<content:encoded><![CDATA[". $body ."]]></content:encoded>\n"; 

# this shit doesn't change
	print XML "\t\t<excerpt:encoded><![CDATA[]]></excerpt:encoded>
		<dc:creator>admin</dc:creator>
		<wp:comment_status>open</wp:comment_status>
		<wp:ping_status>open</wp:ping_status>
		<wp:post_name>retrollect-reviewed-by-techzulu</wp:post_name>
		<wp:status>publish</wp:status>
		<wp:post_parent>0</wp:post_parent>
		<wp:menu_order>0</wp:menu_order>
		<wp:post_type>post</wp:post_type>
		<wp:post_password></wp:post_password>
		<wp:is_sticky>0</wp:is_sticky>\n";
	print XML "\t</item>\n";
	$post_id += 1;

# now the redirect
	print HTACCESS "\tredirect 301 /$permalink http://$newsite/$year/$month/$day/$permalink\n";
}

$dbh->disconnect ();

close(HTACCESS);

print XML "</channel>\n";
print XML "</rss>\n";

close(XML);
