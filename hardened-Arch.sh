#!/bin/bash
#remove unneeded
pacman -R --noconfirm dhcpcd

# initial needfuls
pacman -Syu --noconfirm

# netstat not installed
pacman -S --noconfirm net-tools

# add unpriv user 'useradd'
# set up ssh keys
# secure SSH
#echo "PermitRootLogin no" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
#systemctl restart sshd

# fix locale errors
locale -a 
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen 
sed -i 's/es_US.UTF-8 UTF-8/#es_US.UTF-8 UTF-8/g' /etc/locale.gen 
locale-gen 
locale -a

#set up fail2ban
pacman -S --noconfirm fail2ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl start fail2ban
systemctl enable fail2ban

#ILoveCandy
# sed -i 's/# Misc options/ILoveCandy/' /etc/pacman.conf

#set up IPTABLES
cat << EOF > /etc/iptables/iptables.rules
*filter
# Allow all loopback (lo0) traffic and reject traffic
# to localhost that does not originate from lo0.
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT
# Allow ping.
-A INPUT -p icmp -m state --state NEW --icmp-type 8 -j ACCEPT
# Allow SSH connections.
-A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
# Allow HTTP and HTTPS connections from anywhere
# (the normal ports for web servers).
# -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
# -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
# Allow incoming Longview connections.
# -A INPUT -s longview.linode.com -m state --state NEW -j ACCEPT
# Allow incoming NodeBalancer connections.
# -A INPUT -s 192.168.255.0/24 -m state --state NEW -j ACCEPT
# Allow inbound traffic from established connections.
# This includes ICMP error returns.
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Log what was incoming but denied (optional but useful).
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables_INPUT_denied: " --log-level 7
# Reject all other inbound.
-A INPUT -j REJECT
# Log any traffic that was sent to you
# for forwarding (optional but useful).
-A FORWARD -m limit --limit 5/min -j LOG --log-prefix "iptables_FORWARD_denied: " --log-level 7
# Reject all traffic forwarding.
-A FORWARD -j REJECT
COMMIT
EOF

cat << EOF > /etc/iptables/ip6tables.rules
*filter
# Allow all loopback (lo0) traffic and reject traffic
# to localhost that does not originate from lo0.
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -s ::1/128 -j REJECT
# Allow ICMP
-A INPUT -p icmpv6 -j ACCEPT
# Allow HTTP and HTTPS connections from anywhere
# (the normal ports for web servers).
# -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
# -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
# Allow inbound traffic from established connections.
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Log what was incoming but denied (optional but useful).
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "ip6tables_INPUT_denied: " --log-level 7
# Reject all other inbound.
-A INPUT -j REJECT
# Log any traffic that was sent to you
# for forwarding (optional but useful).
-A FORWARD -m limit --limit 5/min -j LOG --log-prefix "ip6tables_FORWARD_denied: " --log-level 7
# Reject all traffic forwarding.
-A FORWARD -j REJECT
COMMIT
EOF

sudo iptables-restore < /etc/iptables/iptables.rules
sudo ip6tables-restore < /etc/iptables/ip6tables.rules
sudo systemctl start iptables && sudo systemctl start ip6tables
sudo systemctl enable iptables && sudo systemctl enable ip6tables

echo All finished! Rebooting...
(sleep 5; reboot) &
