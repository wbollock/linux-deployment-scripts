#!/usr/bin/env bash

# based on https://github.com/kylemanna/docker-openvpn

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
__EOF__

docker-compose run --rm openvpn ovpn_genconfig -u udp://vpn.jawns.io

cat >> ./openvpn-data/conf/ovpn_env.sh <<__EOF__
declare -x EASYRSA_REQ_COUNTRY=aa
declare -x EASYRSA_REQ_PROVINCE=bb
declare -x EASYRSA_REQ_CITY=cc
declare -x EASYRSA_REQ_ORG=dd
declare -x EASYRSA_REQ_EMAIL=ee
declare -x EASYRSA_REQ_OU=ff
declare -x EASYRSA_REQ_CN=gg
declare -x EASYRSA_DN=org
declare -x EASYRSA_BATCH=y
__EOF__

docker-compose run --rm openvpn ovpn_initpki nopass
docker-compose up -d openvpn

export CLIENTNAME="test-user"

docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass
docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
