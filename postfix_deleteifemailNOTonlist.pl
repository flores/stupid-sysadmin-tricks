#!/usr/bin/ruby

raise "usage #{$0} <path to email list>\n" unless ARGV.count > 0;

file=ARGV[0];

# postqueue -p prints the existing postfix queue
# this awk was just a cheap way to regex using its record separator for multiple newlines.
queue=`postqueue -p |grep -v ^- |awk  'BEGIN{RS="\\n\\n"} ; {print \$1"\t"\$NF}'`;

list_users=`cat #{file}`.split("\n");

queue.split("\n").each do |line|
	# line has the format for <messageid>	<user>
	line=~/^(.+?)\t(.+)$/;
	queueid = $1;
	user = $2;
	unless list_users.find { |u| u == user }
# postsuper -d <messageid> deletes the message 
		system("postsuper -d #{queueid}"); 
		puts "I am deleting #{user} email\n";
# you could postcat instead if wanted, but postcat needs the full path
#		print "Displaying message $queueid for $user\n";
#		system ("find /var/spool/postfix -name \"*$queueid\" -exec postcat {} \;");
	end
end

