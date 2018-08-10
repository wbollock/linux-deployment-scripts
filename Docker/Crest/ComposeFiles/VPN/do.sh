#!/usr/bin/env bash

# based on https://github.com/kylemanna/docker-openvpn

# write out the docker-compose file
cat > docker-compose.yml <<__EOF__
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
    - EASYRSA_REQ_COUNTRY=$COUNTRY
    - EASYRSA_REQ_PROVINCE=$PROVINCE
    - EASYRSA_REQ_CITY=$CITY
    - EASYRSA_REQ_ORG=$ORG
    - EASYRSA_REQ_EMAIL=$EMAIL
    - EASYRSA_REQ_OU=$OU
    - EASYRSA_REQ_CN=$CN
    - EASYRSA_DN=org
    - EASYRSA_BATCH=y
    - CLIENTNAME=$CLIENTNAME
__EOF__

# Generate the OpenVPN server config
docker-compose run --rm openvpn ovpn_genconfig -u udp://$CN

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
echo Client config file is located at /${CLIENTNAME}.ovpn
echo Copy this file to your local system and load it into your OpenVPN client.

# All done.
