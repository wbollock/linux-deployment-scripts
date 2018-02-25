#!/bin/bash

#<UDF name="pubkey" Label="SSH pubkey (installed for root and sudo user)?" example="ssh-rsa ..." />

# initial needfuls
apt-get update
# console-setup = derp
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

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

#set up fail2ban
echo Setting up fail2ban...
apt-get install -y fail2ban
cd /etc/fail2ban
cp fail2ban.conf fail2ban.local
cp jail.conf jail.local
systemctl enable fail2ban
systemctl start fail2ban
echo ...done

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
systemctl enable docker
systemctl start docker

echo All finished!
