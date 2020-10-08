
#!/bin/sh
set -e

php-fpm &
echo "php Running"
/usr/sbin/crond -l 2 -f &
echo "crontab jalan"
supervisord --nodaemon --configuration /etc/supervisord.conf &
echo "supervisor jalan"
echo "ssh Running"
echo 'repo = ssh://root@10.10.0.73:'${SSH_PORT}'/repo/'${NAME_REPO}'.git'
/usr/sbin/sshd -D 
echo "ssh Mati"