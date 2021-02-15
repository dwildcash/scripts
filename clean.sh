#!/bin/bash

# This script automate the cleanup

# find the linux ARCH
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; then
    OS=Redhat
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

################################################################################################
# Ubuntu
################################################################################################
if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Debian" ]
then
echo '****************************************************************************************'
echo '*** Executing Ubuntu Procedure'
echo '****************************************************************************************'
echo
echo '*** Rebuilding Network file... 'packag

echo '*** Updating Packages from Ubuntu Repositories'
/usr/bin/apt-get update 

echo '*** Proceding with the Packages upgrade'
/usr/bin/apt-get upgrade -y 

echo '*** Auto Removing absolete packages'
/usr/bin/apt-get autoremove

echo '*** Cleaning Package'
/usr/bin/apt-get autoclean

echo '*** Removing old kernel'
dpkg -l linux-* | awk '/^ii/{print $2}' | egrep [0-9] | sort -t- -k3,4 --version-sort -r | sed -e "1,/$(uname -r | cut -f1,2 -d"-")/d" | grep -v -e `uname -r | cut -f1,2 -d"-"` | xargs sudo apt-get -y purge

################################################################################################
# RedHat
################################################################################################
elif [ "$OS" == "Redhat" ]
then

echo '****************************************************************************************'
echo '*** Executing Redhat Procedure'
echo '****************************************************************************************'
echo

# Execute Yum update
echo '*** Applying Centos Updates'
yum update -y

echo '*** Stopping Loggin service'
/sbin/service rsyslog stop
/sbin/service auditd stop

echo '*** Remove old kernel'
dnf remove --oldinstallonly --setopt installonly_limit=2 kernel

echo '*** Yum cleanup'
/usr/bin/yum clean all

echo '*** Remove udev persistent rule'
/bin/rm -rf /etc/udev/rules.d/70*

else
echo '*** Warning this OS isnt supported!!!'
exit
fi

################################################################################################
# Common Tasks
################################################################################################
echo
echo '****************************************************************************************'
echo '*** Executing Common Procedure'
echo '****************************************************************************************'
echo

echo '*** Force logrotate and cleanup'
[ -f /etc/logrotate.conf ] && /usr/sbin/logrotate /etc/logrotate.conf -f
/bin/rm -rf /var/log/*-???????? /var/log/*.gz
/bin/rm -rf /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda

echo '*** Truncate audit log'
[ -f /var/log/audit/audit.log ] && /bin/cat /dev/null > /var/log/audit/audit.log
[ -f /var/log/wtmp ] && /bin/cat /dev/null > /var/log/wtmp
[ -f /var/log/lastlog ] && /bin/cat /dev/null > /var/log/lastlog
[ -f /var/log/grubby ] && /bin/cat /dev/null > /var/log/grubby
[ -f /var/log/messages ] && /bin/cat /dev/null > /var/log/messages
[ -f /var/log/syslog ] && /bin/cat /dev/null > /var/log/syslog
[ -f /var/log/debug ] && /bin/cat /dev/null > /var/log/debug
[ -f /var/log/faillog ] && /bin/cat /dev/null > /var/log/faillog
[ -f /var/log/auth.log ] && /bin/cat /dev/null > /var/log/auth.log

echo '*** Cleanup /tmp'
/bin/rm -rf /tmp/*
/bin/rm -rf /var/tmp/*

echo '*** Removing any server wide ssh keys'
/bin/rm -rf /etc/ssh/*key*

unset HISTFILE

echo '*** Remove root ssh info'
/bin/rm -rf /root/.ssh/
/bin/rm -rf /root/anaconda-ks.cfg
/bin/rm -rf /root/.bash_history
/bin/rm -rf /root/install*
history -c
history -w
echo '*** Deleting bash history'
cat /dev/null > ~/.bash_history

echo '****************************************************************************************'
echo '*** Executing Common Procedure'
echo '****************************************************************************************'
