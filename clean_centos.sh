/sbin/service rsyslog stop
/sbin/service auditd stop
echo '*** Force logrotate and cleanup'
[ -f /etc/logrotate.conf ] && /usr/sbin/logrotate /etc/logrotate.conf -f
/bin/rm -rf /var/log/*-???????? /var/log/*.gz
/bin/rm -rf /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda

package-cleanup --oldkernels --count=1

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

echo '*** Deleting bash history'
cat /dev/null > ~/.bash_history
