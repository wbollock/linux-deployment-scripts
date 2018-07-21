#!/bin/bash

#<UDF name="pubkey" Label="SSH pubkey (installed for root and sudo user)?" example="ssh-rsa ..." />
#<UDF name="image"  Label="Docker image to launch?" example="mb101/docker-spigot" />
#<UDF name="params" Label="Extra params to 'docker run'?"/>

# set up ssh pubkey
echo Setting up ssh pubkey...
mkdir -p /root/.ssh
echo "$PUBKEY" > /root/.ssh/authorized_keys
chmod -R 700 /root/.ssh
echo ...done

# disable password over ssh
echo Disabling password login over ssh...
sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i -e "s/#PasswordAuthentication no/PasswordAuthentication no/" /etc/ssh/sshd_config
echo Restarting sshd...
systemctl restart sshd
echo ...done

# Initial needfuls
yum update -y
yum install -y epel-release

#remove unneeded services
echo Removing unneeded services...
yum remove -y avahi chrony
echo ...done

# Set up automatic updates
echo Setting up automatic updates...
yum install -y yum-cron
sed -i -e "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf
echo ...done
# auto-updates complete

#set up fail2ban
echo Setting up fail2ban...
yum install -y fail2ban
cd /etc/fail2ban
cp fail2ban.conf fail2ban.local
cp jail.conf jail.local
sed -i -e "s/backend = auto/backend = systemd/" /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban
echo ...done

# ensure ntp is installed and running
yum install -y ntp
systemctl enable ntpd
systemctl start ntpd

# Remove unneeded docker packages
yum remove -y docker docker-client docker-client-latest docker-common docker-latest \
              docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux \
              docker-engine

# Install Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl enable docker
systemctl start docker

# I hope this goes whale
docker run --restart unless-stopped $PARAMS $IMAGE

echo All finished!
