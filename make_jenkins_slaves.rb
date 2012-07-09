#!/usr/bin/env ruby

# makes some Jenkins ssh slave node xmls
# you MUST set password.  this is usually a common string under <hudson><slaves><slave><password>

require 'rubygems'
require 'optparse'

options = {}

options[:password] = "OMGSEKRETZ"

optparse = OptionParser.new do|opts|
  opts.banner = "Puke some Jenkins ssh slave node xmls.  Usage: #{$0} -h <resolvable host>"
 
  options[:host] = nil 
  opts.on( '-h', '--host <host>', 'host for new jenkins slave. required!' ) do |host|
    options[:host] = host.to_s
  end
  options[:name] = options[:host]
  opts.on( '-n', '--name <name>', 'name for new jenkins slave.  defaults to <host>' ) do |name|
    options[:name] = name.to_s
  end
  options[:desc] = ""
  opts.on( '-d', '--description <string>', 'description. empty by default' ) do |desc|
    options[:desc] = desc.to_s
  end
  options[:user] = "root"
  opts.on( '-u', '--user <string>', 'user for ssh.  root by default' ) do |port|
    options[:user] = user.to_s
  end
  options[:port] = 22
  opts.on( '-p', '--port <int>', 'port for ssh.  22 by default' ) do |port|
    options[:port] = port.to_i
  end
  options[:key] = "/var/lib/jenkins/.ssh/id_rsa"
  opts.on( '-k', '--key <path>', 'private key for ssh.  /var/lib/jenkins/.ssh/id_rsa' ) do |port|
    options[:key] = key.to_s
  end
  options[:executors] = 1
  opts.on( '-e', '--executors <int>', 'executors for new jenkins slave. 1 by default' ) do |executors|
    options[:executors] = executors.to_i
  end
  options[:label] = ""
  opts.on( '-l', '--label <string>', 'labels/tags for slave.  use " " to separate labels' ) do |label|
    options[:label] = label.to_s
  end
  opts.on( '-s', '--secret <string>', "jenkins password.  overrides options[:password] in the head of #{$0}" ) do |secret|
    options[:password] = secret.to_s
  end
  opts.on( '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end
 
begin
  optparse.parse!
  if options[:host] && !options[:name]
    options[:name] = options[:host]
  end
  unless options[:host]
    puts "Error: must set -r/--role"
    puts optparse
    exit 2
  end

rescue OptionParser::InvalidOption
  puts "Error: unknown option"
  puts optparse
  exit 2
end

puts '
    <slave>
      <name>' + options[:name] + '</name>
      <description>' + options[:desc] + '</description>
      <remoteFS>/var/lib/jenkins</remoteFS>
      <numExecutors>' + options[:executors].to_s + '</numExecutors>
      <mode>EXCLUSIVE</mode>
      <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
      <launcher class="hudson.plugins.sshslaves.SSHLauncher">
        <host>' + options[:host] + '</host>
        <port>' + options[:port].to_s + '</port>
        <username>' + options[:user] + '</username>
        <password>' + options[:password] + '</password>
        <privatekey>' + options[:key] +'</privatekey>
      </launcher>
      <label>' + options[:label] +'</label>
      <nodeProperties/>
    </slave>'
