#!/bin/bash

set -o nounset
cd $(dirname $0)

##################################################
# Ubuntu 14.04 specific settings
##################################################

RESTART_IPSEC="ipsec restart"
RESTART_XL2TPD="/etc/init.d/xl2tpd restart"

##################################################
# Common functions and variables
##################################################

source common_functions
declare IP

##################################################
# Script body
##################################################

Step "Check for root privileges"
    if [[ "$UID" != 0 ]]; then
        Error "You don't have root privileges. Please use sudo."
        exit 1
    fi
Done

Step "Get default device and gateway"
    TMP=$(ip route | sed -n -E "s/^default.*via ([0-9.]+).*dev ([[:alnum:]]+).*$/\1#\2/p")
    echo $TMP > /tmp/vpn_dev_gw
    GW=$(echo $TMP | awk -F# '{print $1}')
    DEV=$(echo $TMP | awk -F# '{print $2}')
    Message "Device: $DEV"
    Message "Gateway: $GW"
Done

Step "Add route for the VPN server"
    ip route add 137.189.32.203 via $GW dev $DEV > /dev/null 2>&1
Done

Step "Start IPSec and L2TP services"
    $RESTART_IPSEC
    $RESTART_XL2TPD
    sleep 1
Done

Step "Connect to the VPN server"
    echo "c connect" > /var/run/xl2tpd/l2tp-control
    for (( i = 0; i < 10; i++ )); do
        ip addr show dev ppp0 > /dev/null 2>&1
        if [[ $? == 0 ]]; then
            break
        fi
        if [[ $i == 9 ]]; then
            Error "Device ppp0 is not found. Connection failed."
            exit 1
        fi
        sleep 1
    done
Done

Step "Change default route to ppp0"
    while [[ 1 ]]; do
        ip route del 137.189.32.203 dev ppp0 > /dev/null 2>&1
        ip route del default > /dev/null 2>&1
        ip route add default dev ppp0 > /dev/null 2>&1
        if [[ $? == 0 ]]; then
            break
        fi
        sleep 1
    done
    sleep 2
    ip route del 137.189.32.203 dev ppp0 > /dev/null 2>&1
    echo "nameserver 137.189.192.3" >> /tmp/resolv.conf
    echo "nameserver 137.189.192.6" >> /tmp/resolv.conf
    cat /etc/resolv.conf >> /tmp/resolv.conf
    mv /tmp/resolv.conf /etc/resolv.conf
    chmod 644 /etc/resolv.conf
Done

IP=$(ip addr show dev ppp0 2>&1 | sed -n -E "s/^[[:space:]]*inet[[:space:]]+([0-9.]+).*$/\1/p")

Message "The connection should be established now."
Message "Your IP is: $IP"

# vim: set tabstop=4 shiftwidth=4:
