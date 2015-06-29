#!/bin/sh

### setup ubuntu
chmod +x /usr/sbin/policy-rc.d
dpkg-divert --local --rename --add /sbin/initctl
cp -a /usr/sbin/policy-rc.d /sbin/initctl
sed -i 's/^exit.*/exit 0/' /sbin/initctl
echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean
echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean
echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean
echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages
echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes


### run install
apt-get update
apt-get install -y supervisor

### lampp
apt-get install -y apache2
apt-get install -y mysql-server
apt-get install -y php5 libapache2-mod-php5
# lib php5
apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

### open ssh server (sshd)
apt-get install -y openssh-server

### utility
apt-get install -y git

### phalcon2
apt-get install -y php5-dev php5-mysql gcc libpcre3-dev

cd /tmp/
git clone --depth=1 git://github.com/phalcon/cphalcon.git
cd cphalcon/build
sudo ./install

cp /tmp/phalcon.ini /etc/php5/mods-available/

php5enmod mcrypt
php5enmod phalcon

### apache2
mkdir -p /var/lock/apache2 /var/run/apache2
a2enmod rewrite

###### setup  ######
mkdir -p /var/log/supervisor

### openssh-server (sshd)
mkdir /var/run/sshd
echo 'root:password' | chpasswd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#### SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#### ENV NOTVISIBLE "in users profile"
echo "export VISIBLE=now" >> /etc/profile

mkdir /root/.ssh
chmod o-rwx /root/.ssh

#### mysql-server
## enable any bind
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

## grant root
/usr/sbin/mysqld &
sleep 10
echo "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql


##### finaly #####
### clean packages
apt-get clean
apt-get autoclean
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*