#!/bin/bash

set -o nounset
cd $(dirname $0)

##################################################
# Ubuntu 14.04 specific settings
##################################################

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

Step "Get original device and gateway"
    GW=$(awk -F# '{print $1}' /tmp/vpn_dev_gw)
    DEV=$(awk -F# '{print $2}' /tmp/vpn_dev_gw)
    Message "Device: $DEV"
    Message "Gateway: $GW"
Done

Step "Disconnect from the VPN server"
    echo "d" > /var/run/xl2tpd/l2tp-control
    sleep 1
Done

Step "Restore default route"
    ip route del default > /dev/null 2>&1
    ip route add default via $GW dev $DEV > /dev/null 2>&1
    sed -i /137\.189\.192\.[36]/d /etc/resolv.conf
Done

Message "The connection should be disconnected."

# vim: set tabstop=4 shiftwidth=4:
