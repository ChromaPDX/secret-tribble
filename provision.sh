# THIS DEPENDS ON ubuntu/trusty64 VAGRANT IMAGE

apt-get update
apt-get upgrade -y

# clean up chef packages
apt-get remove -y chef chef-zero

# clean up puppet packages
apt-get remove -y puppet puppet-common

# clean up existing ruby packages
apt-get remove -y libruby1.9.1 ruby ruby-augeas ruby-diff-lcs ruby-erubis ruby-hashie ruby-hiera ruby-highline ruby-ipaddress ruby-json ruby-mime-types	ruby-mixlib-authentication ruby-mixlib-cli ruby-mixlib-config ruby-mixlib-log ruby-mixlib-shellout ruby-net-ssh ruby-net-ssh-gateway ruby-net-ssh-multi ruby-rack ruby-rest-client ruby-rgen ruby-safe-yaml ruby-shadow ruby-sigar ruby-systemu ruby-yajl ruby1.9.1

# install ruby 2.1.4
apt-get install -y build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev
cd /tmp
wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.4.tar.gz
tar -xvzf ruby-2.1.4.tar.gz
cd ruby-2.1.4/
./configure --prefix=/usr/local
make
make install

# install bundler
gem install bundler

# install postgresql
apt-get install -y postgresql libpq-dev

# create chroma_dev database and 'vagrant' user
sudo -H -u postgres bash -c "createdb chroma_dev"
sudo -H -u postgres psql -c "createdb chroma_test"
sudo -H -u postgres psql -c "create user vagrant password 'vagrant'"

# clean up abandoned packages
apt-get autoremove -y

# update locations
updatedb
