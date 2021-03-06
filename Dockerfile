#name of container: docker-dspace
#versison of container: 0.5.3
FROM quantumobject/docker-tomcat8
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

#add repository and update the container
#Installation of necessary package/software for this containers...
RUN echo "deb http://archive.ubuntu.com/ubuntu `cat /etc/container_environment/DISTRIB_CODENAME`-backports main restricted " >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y -q --force-yes python-software-properties \
                                            software-properties-common \
                                            postgresql \
                                            openjdk-7-jdk \
                                            ant \
                                            git \
                                            unzip \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

##Adding Deamons to containers
# to add postgresqld deamon to runit
RUN mkdir /etc/service/postgresqld /var/log/postgresqld ; sync
RUN mkdir /etc/service/postgresqld/log
COPY postgresqld.sh /etc/service/postgresqld/run
COPY postgresqld-log.sh /etc/service/postgresqld/log/run
RUN chmod +x /etc/service/postgresqld/run /etc/service/postgresqld/log/run \
    && cp /var/log/cron/config /var/log/postgresqld/ \
    && chown -R postgres /var/log/postgresqld

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY dspace_tomcat8.conf /tmp/dspace_tomcat8.conf
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf; sync \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf

##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups

#script to execute to create administrator account 
COPY create-admin.sh /sbin/create-admin
RUN chmod +x /sbin/create-admin

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 8080

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
