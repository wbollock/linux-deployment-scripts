Install and set up ZNC.

This script sets up a hardened CentOS 7 deployment using the steps in the Linode "Securing your Server" guide here:
https://www.linode.com/docs/security/securing-your-server

Then sets up ZNC using the steps here:
http://wiki.znc.in/Installation#Fedora.2FCentOS.2FRed_Hat_Enterprise_Linux

Because of the differences in maintenance of the ZNC package across distributions, CentOS 7 is used for the latest-and-greatest. See http://wiki.znc.in/Installation for more info on why this is the case.

ZNC will be configured to start automatically on boot but will remain unconfigured after installation. The server will automatically reboot once the script completes. After rebooting, you will need to run the following steps to complete installation and open the firewall port:

```
sudo -u znc znc --makeconf
sudo firewall-cmd --zone=public --add-port=####/tcp
sudo firewall-cmd --zone=public --add-port=####/tcp --permanent
```
