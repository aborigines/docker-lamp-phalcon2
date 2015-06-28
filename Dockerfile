#FROM scratch
#ADD ubuntu-trusty-core-cloudimg-amd64-root.tar.gz /
FROM ubuntu:14.04


###### copy file
ADD policy-rc.d /usr/sbin/policy-rc.d

## setup file
ADD setup.bash /tmp/setup.bash

### repo file
COPY sources.list /etc/apt/sources.list

### supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

### phalcon config file
ADD phalcon.ini /tmp/phalcon.ini

##### run setup.bash
RUN /bin/bash /tmp/setup.bash

# volumes for MYSQL
VOLUME ["/var/lib/mysql"]

# open port
EXPOSE 22 80 3306

# run file setup.bash 
CMD ["/usr/bin/supervisord"]