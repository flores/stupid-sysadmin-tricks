use strict;
use DBI;

# the head of the xml
print "<?xml version=\"1.0\"?>\n";
print '
<rss version="2.0"
        xmlns:excerpt="http://wordpress.org/export/1.1/excerpt/"
        xmlns:content="http://purl.org/rss/1.0/modules/content/"
        xmlns:wfw="http://wellformedweb.org/CommentAPI/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:wp="http://wordpress.org/export/1.1/"
>
';
print '<channel>
	<title>Somecompany</title>
	<link>http://somesite</link>
	<description>Changing the World One App at a Time</description>
	<pubDate>Wed, 05 Oct 2011 19:59:13 +0000</pubDate>
	<language>en</language>
	<wp:wxr_version>1.1</wp:wxr_version>
	<wp:base_site_url>http://somesite.com</wp:base_site_url>
	<wp:base_blog_url>http://somesite.com</wp:base_blog_url>
	<wp:author><wp:author_id>1</wp:author_id><wp:author_login>admin</wp:author_login><wp:author_email>wordpressadmin@borderstylo.com</wp:author_email><wp:author_display_name><![CDATA[SomeSite]]></wp:author_display_name><wp:author_first_name><![CDATA[Social]]></wp:author_first_name><wp:author_last_name><![CDATA[Mosaic]]></wp:author_last_name></wp:author>
	<generator>http://wordpress.org/?v=3.2.1</generator>\n';


# the actual loop

my $dbh = DBI->connect ("DBI:mysql:somedb:somehost", "someuser", "somepass",
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
	print "\t<item>\n";
	print "\t\t<title>$title</title>\n";
	print "\t\t<link>http://somesite.com/$year/$month/$day/$permalink</link>\n";
	print "\t\t<pubDate>$published_at</pubDate>\n";
	print "\t\t<post_date>$published_at</post_date>\n";
	print "\t\t<post_id>$post_id</post_id>\n";
	print "\t\t<guid isPermaLink='false'>http://somesite.com/?p=$post_id</guid>\n";
	print "\t\t<content:encoded><![CDATA[". $body ."]]></content:encoded>\n"; 

# this shit doesn't change
	print "\t\t<excerpt:encoded><![CDATA[]]></excerpt:encoded>
		<dc:creator>admin</dc:creator>
		<wp:comment_status>open</wp:comment_status>
		<wp:ping_status>open</wp:ping_status>
		<wp:status>publish</wp:status>
		<wp:post_parent>0</wp:post_parent>
		<wp:menu_order>0</wp:menu_order>
		<wp:post_type>post</wp:post_type>
		<wp:post_password></wp:post_password>
		<wp:is_sticky>0</wp:is_sticky>\n";
	print "\t</item>\n";
	$post_id += 1;
}
$dbh->disconnect ();
print "</channel>\n";
print "</rss>\n";
