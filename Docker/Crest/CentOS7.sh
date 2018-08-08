#!/bin/bash

#<UDF name="PUBKEY" Label="SSH pubkey (installed for root and sudo user)?" example="ssh-rsa ..." />
#<UDF name="RESOURCE"  Label="Resource to download?" example="URL to Dockerfile or docker-compose.yml" default="" />
#<UDF name="RUNCMD" Label="Command to run?" example="docker run --name spigot --restart unless-stopped -e JVM_OPTS=-Xmx4096M -p 25565:25565 -itd mb101/docker-spigot" />
#<UDF name="SKIP" Label="Skip updates and server hardening?" example="Not recommended for production deployments" oneOf="no,yes" default="no" />

if [[ ! $PUBKEY ]]; then read -p "SSH pubkey (installed for root and sudo user)?" PUBKEY; fi
if [[ ! $RUNCMD ]]; then read -p "Command to run?" RUNCMD; fi
if [[ ! $SKIP ]]; then read -p "Skip updates and server hardening?" SKIP; fi

install_pubkey() {
  # set up ssh pubkey
  echo Setting up ssh pubkey...
  mkdir -p /root/.ssh
  echo "$PUBKEY" >> /root/.ssh/authorized_keys
  chmod -R 700 /root/.ssh
  echo ...done
}

install_epel_release() {
  yum install -y epel-release
}

disable_PasswordAuthentication() {
  # disable password over ssh
  echo Disabling password login over ssh...
  sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
  sed -i -e "s/#PasswordAuthentication no/PasswordAuthentication no/" /etc/ssh/sshd_config
  echo Restarting sshd...
  systemctl restart sshd
  echo ...done
}

do_yum_update() {
  # Initial needfuls
  yum update -y
}

remove_unneeded() {
  # remove unneeded services
  echo Removing unneeded services...
  yum remove -y avahi chrony
  echo ...done
}

configure_yum_cron() {
  # Set up automatic updates
  echo Setting up automatic updates...
  yum install -y yum-cron
  sed -i -e "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf
  echo ...done
}

configure_fail2ban() {
  # set up fail2ban
  echo Setting up fail2ban...
  yum install -y fail2ban
  cd /etc/fail2ban
  cp fail2ban.conf fail2ban.local
  cp jail.conf jail.local
  sed -i -e "s/backend = auto/backend = systemd/" /etc/fail2ban/jail.local
  systemctl enable fail2ban
  systemctl start fail2ban
  cd /
  echo ...done
}

configure_ntp() {
  # ensure ntp is installed and running
  yum install -y ntp
  systemctl enable ntpd
  systemctl start ntpd
}

clean_docker() {
  # Remove unneeded docker packages
  yum remove -y docker docker-client docker-client-latest docker-common docker-latest \
                docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux \
                docker-engine
}

install_docker() {
  # Install Docker
  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce
  systemctl enable docker
  systemctl start docker
}

install_compose() {
  yum install -y python-pip
  pip install -U pip
  pip install docker-compose
}

fetch_and_exec() {
  if [[ "$RESOURCE" != "" ]]; then
    yum install -y wget
    wget $RESOURCE
  fi
  # needfuls done
  echo "=== Docker install complete ==="
  echo -n "Sleeping for 2 seconds before moving on... "
  sleep 2
  echo "ship it!"
  $RUNCMD
}

main() {
  # Always install pubkey, and do it early
  install_pubkey
  # Always install epel-release. Other things depend on it
  install_epel_release
  if [[ "$SKIP" = "no" ]]; then
    disable_PasswordAuthentication
    do_yum_update
    remove_unneeded
    configure_yum_cron
    configure_fail2ban
    configure_ntp
    echo "=== Server hardening complete ==="
    echo -n "Waiting for 2 seconds before starting Docker things... "
    sleep 2
    echo "here we go!"
  fi
  clean_docker
  install_docker
  install_compose
  fetch_and_exec
}

main
