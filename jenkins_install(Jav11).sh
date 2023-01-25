#!/bin/bash

# This sh script is for Jenkins installation on CentOS AWS Linux Machine x64
# Please run this file using sudo access
# You can also give full permission to this file using chmod 777 Jenkins_Install.sh
# This script will yum update and install all the dependencies for jenkins and openjdk
# Note: this script has a parallel yum installations and can throw an waiting error
  # "Existing lock /var/run/yum.pid: another copy is running as pid 2077.
  # Another app is currently holding the yum lock; waiting for it to exit..." 
# Recomended to wait till yum is free or you can alternatively use dnf package manger to install ad edit the lines.


Dependencies()
{
echo doing yum update 
sudo yum update
echo "Install script for Jenkins Server on Centos 7"
echo "Installing Dependencies"
sudo amazon-linux-extras install epel -y
yum install epel-release -y
firewall -cmd --add -port=8080/tcp --permanent --zone=public
firewall -cmd --reload
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX-disabled/g' /etc/selinux/config
}

# OpenJDK 8 will be installed and javahome path will created
Java8Installation()
{
if [ "$(dpkg-query -W -f='${Status}' java-1.8.0-openjdk-devel 2>/dev/null | grep -c "ok installed")" -eq 0 ]
then
    yum install -y java-1.8.0-openjdk-devel
    echo "verifing java installation"
    java -version
    echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/" >> /home/ec2-user/.bash_profile && echo "JAVA_HOME path added to .bash_profile"
fi 

}

# Installing latest Jenkins
JenkinsInstallation()
{
echo "Intalling Jenkins"
yum install curl
if [ "$(dpkg-query -W -f='${Status}' jenkins 2>/dev/null | grep -c "ok installed")" -eq 0 ]
then
    curl --silent --location https://pkg.jenkins.io/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum -y install jenkins
    echo "starting and enabling jenkins"
    systemctl start jenkins
    systemctl enable jenkins
fi 

}

# Invoking two functions "Dependencies,Java8Installation, JenkinsInstallation"
Dependencies
Java8Installation
JenkinsInstallation

echo "Jenkins installation complete"  
sleep 2

echo "-----------------------"
cat /var/lib/jenkins/secrets/initialAdminPassword

sleep 2
echo "-----------------------"
echo "copy the secret password from above to unlock jenkins"
echo "Use http://your_ip_or_domain:8080"

# script completed
