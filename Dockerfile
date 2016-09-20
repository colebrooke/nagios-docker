# Dockerfile for nagios-docker

FROM ubuntu:16.04

MAINTAINER Justin Miller <justin@mycomputer.me.uk>

### TODO:
### ssl, configurations files potentially on the host rather than in the container
### localhost ping checks broken


RUN apt-get update
RUN apt-get install sudo
#### non-interactive mysql install
RUN echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
RUN echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
RUN apt-get -y install mysql-server-5.7

RUN apt-get install -y -q	vim \
				apache2 \
				apache2-utils \
				daemon \ 
				build-essential \
				php7.0 \
				php7.0-gd \
				php7.0-mysql \
				wget \
				unzip \
				libgd2-xpm-dev \
				libapache2-mod-php7.0 
				#postfix \
				#mailutils 

#### set up mysql
RUN mkdir -p /opt/mysql/mysql/data/
RUN mysqld --initialize-insecure --basedir=/opt/mysql/mysql --datadir=/opt/mysql/mysql/data 

#### add user & group
RUN useradd nagios
RUN groupadd nagcmd
RUN usermod -a -G nagcmd nagios
RUN usermod -a -G nagcmd www-data

#### download latest stable version of nagios
RUN cd /tmp/ && wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.1.tar.gz
RUN mkdir /tmp/nagios-build
RUN tar -zxvf /tmp/nagios-4.2.1.tar.gz -C /tmp/nagios-build
WORKDIR "/tmp/nagios-build/nagios-4.2.1"

#### run configure script and build from source
RUN ./configure --with-nagios-group=nagios --with-command-group=nagcmd
RUN make all
RUN make install
RUN make install-init
RUN make install-config
RUN make install-commandmode
#### custom location for 
RUN /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-enabled/nagios.conf
RUN make install-exfoliation

#### set nagiosadmin http password to "password" <<< should be changed
RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin password

#### copy the nagios init script from the project
COPY nagios-init /etc/init.d/nagios
RUN chmod +x /etc/init.d/nagios

#### install nagios plugins
RUN cd /tmp && wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
RUN mkdir /tmp/nagios-plugins/
RUN tar -zxvf /tmp/nagios-plugins-2.1.1.tar.gz -C /tmp/nagios-plugins/
RUN ls -la /tmp/nagios-plugins/
WORKDIR "/tmp/nagios-plugins/nagios-plugins-2.1.1/"

#### configure nagios plugins
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios
RUN make
RUN make install

#### verify the nagios configuration
RUN /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

RUN a2enmod cgi

#### add start services script
WORKDIR "/usr/local/nagios/"
COPY start-services.sh /usr/local/nagios/start-services.sh
RUN chmod +x /usr/local/nagios/start-services.sh

#### copy localhost checks into the container
COPY objects/localhost.cfg /usr/local/nagios/etc/objects/localhost.cfg

#### service startup commands
#### requires && tailf otherwise the container will exit
ENTRYPOINT /usr/local/nagios/start-services.sh && tailf /usr/local/nagios/var/nagios.log


