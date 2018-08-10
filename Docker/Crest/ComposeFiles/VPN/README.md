# README

This works, it's just a bit more complicated than a single `docker-compose.yml` file can handle.

`do.sh` is a wrapper around the moving parts. It does the following:

- writes out the `docker-compose.yml` file with variables for `easyrsa` cert generation
- calls `docker-compose` to init the OpenVPN server
- creates a configuration file for the `$CLIENTNAME` user (currently `test-user`)
- writes that config file out

None of these certs are protected with passwords, so this is only intended as a proof-of-concept. However, this has been tested as does work. 

After `do.sh` completes, you can find the configuration file named `/${CLIENTNAME}.ovpn`. By default, `$CLIENTNAME` is `test-user`. You will need to copy this config file from the OpenVPN server to your client machine and load it into your OpenVPN client software. You can copy this file to your system using `scp`. Here's an example command:

```
scp root@$IP:/test-user.ovpn .
```

This has been tested with the Mac client [Tunnelblick](https://tunnelblick.net/)
