# README

This works, it's just a bit more complicated than a single `docker-compose.yml` file can handle.

`do.sh` is a wrapper around this. It:

- writes out the `docker-compose.yml` file
- calls `docker-compose` to init the OpenVPN server
- writes variables for `easyrsa` cert generation
- creates a configuration file for the `$CLIENTNAME` user (currently `test-user`)
- writes that config file out

None of these certs are protected with passwords, so this is only intended as a proof-of-concept. However, has been tested as is working. After `do.sh` completes, you can find the configuration file named `test-user.ovpn`.

This has been tested with the Mac client [Tunnelblick](https://tunnelblick.net/)
