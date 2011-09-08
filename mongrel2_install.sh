
# we're pulling zmq libs from sid via apt-pinning
echo "deb     http://http.us.debian.org/debian   sid         main contrib non-free" > /etc/apt/sources.list.d/unstable.list
echo "Package: *
Pin: release a=stable
Pin-Priority: 700

Package: *
Pin: release a=sid
Pin-Priority: 600" > /etc/apt/preferences

apt-get update
apt-get install -y build-essential sqlite3 libsqlite3-dev ruby1.8 ruby1.8-dev rubygems1.8 
apt-get install -t sid libzmq-dev libzmq1

# install zeromq
gem install zmq

# install mongrel2 
LASTDIR=`pwd`
cd /usr/local/
wget http://mongrel2.org/static/downloads/mongrel2-1.7.5.tar.bz2
tar -xjvf mongrel2-1.7.5.tar.bz2
cd mongrel2-1.7.5/
make clean all && sudo make install
cd ..
ln -s mongrel2-1.7.5/ mongrel
echo 'PATH=$PATH:/usr/local/mongrel/bin && export PATH' >> /etc/environment
PATH=$PATH:/usr/local/mongrel/bin
export PATH

# go back
apt-get purge -y build-essential
apt-get -y autoremove
cd $LASTDIR

