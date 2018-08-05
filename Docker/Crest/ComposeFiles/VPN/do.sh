#!/usr/bin/env bash

# based on https://github.com/kylemanna/docker-openvpn

# write out the docker-compose file
cat >> docker-compose.yml <<__EOF__
version: '2'
services:
  openvpn:
    cap_add:
    - NET_ADMIN
    image: kylemanna/openvpn
    container_name: openvpn
    ports:
    - "1194:1194/udp"
    restart: always
    volumes:
    - ./openvpn-data/conf:/etc/openvpn
    environment:
    - EASYRSA_REQ_COUNTRY=aa
    - EASYRSA_REQ_PROVINCE=bb
    - EASYRSA_REQ_CITY=cc
    - EASYRSA_REQ_ORG=dd
    - EASYRSA_REQ_EMAIL=ee
    - EASYRSA_REQ_OU=ff
    - EASYRSA_REQ_CN=gg
    - EASYRSA_DN=org
    - EASYRSA_BATCH=y
    - CLIENTNAME="test-user"
    - HOSTNAME=vpn.jawns.io
__EOF__

# Generate the OpenVPN server config
docker-compose run --rm openvpn ovpn_genconfig -u udp://$HOSTNAME

# Init OpenVPN PKI, skip prompting for password
docker-compose run --rm openvpn ovpn_initpki nopass

# Start OpenVPN server
docker-compose up -d openvpn

# Build client keychain
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass

# Build client config file from keychain
docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn

# cat the client config file if desired
# cat $CLIENTNAME.ovpn

# All done.
