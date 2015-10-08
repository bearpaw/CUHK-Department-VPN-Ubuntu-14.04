#!/bin/bash

set -o nounset
cd $(dirname $0)

##################################################
# Ubuntu 14.04 specific settings
##################################################

PKG_LIST=("strongswan" "xl2tpd" "ppp" "isc-dhcp-client")
PKG_INSTALL="apt-get install"
STRONGSWAN_PATH="/etc"

InstallCFGs() {
    Backup $STRONGSWAN_PATH/ipsec.conf
    Backup $STRONGSWAN_PATH/ipsec.secrets
    Backup /etc/xl2tpd/xl2tpd.conf
    Backup /etc/ppp/options
    Backup /etc/ppp/options.xl2tpd
    Backup /etc/ppp/pap-secrets

    cd conf
    echo "include $STRONGSWAN_PATH/ipsec.d/ee/ee.conf" >> $STRONGSWAN_PATH/ipsec.conf
    echo "include $STRONGSWAN_PATH/ipsec.d/ee/ee.secrets" >> $STRONGSWAN_PATH/ipsec.secrets
    mkdir -p $STRONGSWAN_PATH/ipsec.d/ee
    cp ee.conf $STRONGSWAN_PATH/ipsec.d/ee/ee.conf
    cp ee.secrets $STRONGSWAN_PATH/ipsec.d/ee/ee.secrets
    cp xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
    cp options /etc/ppp/options
    cp options.xl2tpd /etc/ppp/options.xl2tpd
}

InstallUserInfo() {
    echo "$1 vpn.ee.cuhk.edu.hk \"$2\"" >> /etc/ppp/pap-secrets
    echo "name $1" >> /etc/ppp/options.xl2tpd
}

PostInstall() {
    ChPerm $STRONGSWAN_PATH/ipsec.conf
    ChPerm $STRONGSWAN_PATH/ipsec.secrets 600
    ChPerm $STRONGSWAN_PATH/ipsec.d/ee/ee.conf
    ChPerm $STRONGSWAN_PATH/ipsec.d/ee/ee.secrets 600
    ChPerm /etc/xl2tpd/xl2tpd.conf
    ChPerm /etc/ppp/pap-secrets 600
    ChPerm /etc/ppp/options
    ChPerm /etc/ppp/options.xl2tpd
}

##################################################
# Common functions and variables
##################################################

source common_functions

##################################################
# Script body
##################################################

Step "Check for root privileges"
    if [[ "$UID" != 0 ]]; then
        Error "You don't have root privileges. Please use sudo."
        exit 1
    fi
Done

Step "Install required packages"
    Message "The script will try to install the following packages:"
    for pkg in ${PKG_LIST[@]}; do
        Message " - $pkg"
    done
    $PKG_INSTALL ${PKG_LIST[@]}
    if [[ $? != 0 ]]; then
        Error "Installation failed! Please install the packages manually."
        exit 1
    fi
Done


Step "Install config files"
    InstallCFGs
Done

Step "Set up CSE ID and password"
    Message "Please enter your CSE ID and password."
    Message "Note that for secure reason, the password will not be shown."
    echo ""
    echo -n "ID: "
    read ID
    while [[ 1 ]]; do
        echo -n "Password: "
        read -s PW1
        echo ""
        echo -n "Repeat the password: "
        read -s PW2
        echo ""
        if [[ $PW1 != $PW2 ]]; then
            Error "Password not match! Try again."
        else
            break
        fi
    done
    InstallUserInfo $ID $PW1
Done

Step "Change file permission"
    PostInstall
Done

Message "You may now use vpn_connect.sh to connect to the VPN."

# vim: set tabstop=4 shiftwidth=4:
