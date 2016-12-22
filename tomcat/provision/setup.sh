#!/bin/bash

# - Variables ----------------------------------------------------------------------
SOURCES_DIR=/vagrant/websource
STATIC_RESOURCES_DIR=/vagrant/websource/static
TOMCAT_SERVER_CONFIG_FILE=/opt/tomcat/apache-tomcat-8.0.27/conf/server.xml
TOMCAT_USERS_CONFIG_FILE=/opt/tomcat/apache-tomcat-8.0.27/conf/tomcat-users.xml
TOMCAT_STARTUP_SCRIPT=/opt/tomcat/apache-tomcat-8.0.27/bin/startup.sh
TOMCAT_SHUTDOWN_SCRIPT=/opt/tomcat/apache-tomcat-8.0.27/bin/shutdown.sh
APACHE_STATIC_VH_CONFIG=/etc/apache2/sites-available/websourcestatic.conf
APACHE_PORTS_CONFIG=/etc/apache2/ports.conf
APACHE_VH_SITENAME=websourcestatic.conf

# - Actions ------------------------------------------------------------------------
echo "Start provisioning virtual machine..."

# Install Java 8
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

sudo export JAVA_HOME=/opt/java/jdk1.8.0_60
sudo export PATH=$PATH:$JAVA_HOME/bin

# Install Maven 3
sudo apt-get remove -y --force-yes maven
sudo apt-get remove -y --force-yes maven2
sudo add-apt-repository "deb http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main"
#sudo add-apt-repository ppa:natecarlson/maven3
#ENTER
sudo apt-get update
sudo apt-get install -y --force-yes maven3
sudo ln -s /usr/bin/mvn3 /usr/bin/mvn
sudo export M2_HOME=/usr/share/maven3
sudo export M2=$M2_HOME/bin
sudo export PATH=$M2:$PATH

# Install NodeJs and NPM
#sudo apt-get install -y --force-yes nodejs
#sudo ln -s /usr/bin/nodejs /usr/bin/node
#sudo apt-get install -y --force-yes npm
#sudo npm install -g grunt

# Install and configure Apache2
sudo apt-get install -y --force-yes apache2
sudo cp /etc/apache2/sites-available/000-default.conf $APACHE_STATIC_VH_CONFIG
#sudo sed -i 's/\/var\/www\/html/\/vagrant\/websource\/static/' $APACHE_STATIC_VH_CONFIG
#sudo sed -i 's/:80/:81/' $APACHE_STATIC_VH_CONFIG
sudo echo '<VirtualHost *:81>
        ServerAdmin webmaster@localhost
        DocumentRoot /vagrant/websource/static
        <Directory />
                Options Indexes FollowSymLinks Includes ExecCGI
                AllowOverride All
                Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>' > $APACHE_STATIC_VH_CONFIG
sudo sed -i 's/80/81/' $APACHE_PORTS_CONFIG
#sudo chmod 777 $STATIC_RESOURCES_DIR
sudo a2ensite $APACHE_VH_SITENAME
sudo service apache2 restart

# Setup Tomcat server
sudo sh $TOMCAT_SHUTDOWN_SCRIPT
#sudo chmod 777 /opt/tomcat/apache-tomcat-8.0.27/conf/*
sudo sed -i 's/port="8005"/port="8006"/' $TOMCAT_SERVER_CONFIG_FILE
sudo sed -i 's/port="8080"/port="8181"/' $TOMCAT_SERVER_CONFIG_FILE
sudo sed -i 's/redirectPort="8443"/redirectPort="8444"/' $TOMCAT_SERVER_CONFIG_FILE
sudo sed -i 's/port="8009"/port="8010"/' $TOMCAT_SERVER_CONFIG_FILE
sudo echo '<?xml version="1.0" encoding="utf-8"?><tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0"><role rolename="manager-gui"/><role rolename="manager-script"/><role rolename="manager-jmx"/><role rolename="manager-status"/><role rolename="admin-gui"/><role rolename="admin-script"/><user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/></tomcat-users>' > $TOMCAT_USERS_CONFIG_FILE
sudo sh $TOMCAT_STARTUP_SCRIPT

# Install node libs in project dir
# cd $SOURCES_DIR && sudo npm i --no-optional

echo "Finished provisioning virtual machine."