#FROM scratch
#ADD ubuntu-trusty-core-cloudimg-amd64-root.tar.gz /
FROM ubuntu:14.04


###### copy file
ADD config /tmp/config

##### run setup.bash
RUN /bin/bash /tmp/config/setup.bash

# volumes for MYSQL
VOLUME ["/var/lib/mysql"]

# open port
EXPOSE 22 80 3306

# run file setup.bash 
CMD ["/usr/bin/supervisord"]