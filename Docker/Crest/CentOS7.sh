#!/bin/bash

#<UDF name="pubkey" Label="SSH pubkey (installed for root and sudo user)?" example="ssh-rsa ..." />
#<UDF name="method" Label="Launch method?" oneOf="docker-run,docker-compose" default="docker-run" />
#<UDF name="image"  Label="Docker thing to launch?" example="Image name for docker run (i.e. mb101/docker-spigot) or full URL to docker-compose.yml for docker-compose" />
#<UDF name="params" Label="Extra params to 'docker run'?"/>
#<UDF name="skip" Label="Skip updates and server hardening?" example="Not recommended for production deployments" oneOf="no,yes" default="no" />

if [[ ! $PUBKEY ]]; then read -p "SSH pubkey (installed for root and sudo user)?" PUBKEY; fi
if [[ ! $IMAGE ]]; then read -p "Docker image to launch?" IMAGE; fi
if [[ ! $PARAMS ]]; then read -p "Extra params to 'docker run'?" PARAMS; fi

echo pubkey = $PUBKEY
echo method = $METHOD
echo image  = $IMAGE
echo params = $PARAMS
echo skip   = $SKIP

exit

install_pubkey() {
  # set up ssh pubkey
  echo Setting up ssh pubkey...
  mkdir -p /root/.ssh
  echo "$PUBKEY" > /root/.ssh/authorized_keys
  chmod -R 700 /root/.ssh
  echo ...done
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
  yum install -y epel-release
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

fetch_and_kickstart() {
# just docker-compose things
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# I hope this goes whale
if   [[ "$method" == "docker-run" ]]; then
    docker run --restart unless-stopped $PARAMS $IMAGE
elif [[ "$method" == "docker-compose" ]]; then
    curl -o docker-compose.yml -L $IMAGE
    docker-compose up
else
    echo "method was not one of 'docker-run' or 'docker-compose'. I don't know what to do. Stopping."
fi
}

main() {
  if [[ "$SKIP" = "no" ]]; then
    install_pubkey
    disable_PasswordAuthentication
    do_yum_update
    remove_unneeded
    configure_yum_cron
    configure_fail2ban
    configure_ntp
  fi
  clean_docker
  install_docker
  fetch_and_kickstart
}

main
