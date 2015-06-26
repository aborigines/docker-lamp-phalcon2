#FROM scratch
#ADD ubuntu-trusty-core-cloudimg-amd64-root.tar.gz /
FROM ubuntu:14.04

# a few minor docker-specific tweaks
# see https://github.com/docker/docker/blob/master/contrib/mkimage/debootstrap
RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
	\
	&& dpkg-divert --local --rename --add /sbin/initctl \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
	\
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
	\
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
	\
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
	\
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes

COPY sources.list /etc/apt/sources.list

## copy file source list to fast install (cache repo)
#COPY lists /var/lib/apt/lists/


### supervisor manage service
RUN apt-get install -y supervisor

### lampp
RUN apt-get install -y apache2
RUN apt-get install -y mysql-server
RUN apt-get install -y php5 libapache2-mod-php5
# lib php5
RUN apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

### open ssh server (sshd)
RUN apt-get install -y openssh-server

### utility
RUN apt-get install -y git


##### config #####
### supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor


### apache2
RUN mkdir -p /var/lock/apache2 /var/run/apache2

### mysql-server
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
ADD set-mysql-password.sh /tmp/set-mysql-password.sh
RUN /bin/sh /tmp/set-mysql-password.sh


### openssh-server (sshd)
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN mkdir /root/.ssh
RUN chmod o-rwx /root/.ssh


##### finaly #####
# clean packages
RUN apt-get clean
RUN apt-get autoclean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# volumes MYSQL
VOLUME ["/var/lib/mysql"]

EXPOSE 22 80 3306
CMD ["/usr/bin/supervisord"]