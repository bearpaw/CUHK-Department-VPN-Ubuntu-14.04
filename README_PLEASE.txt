[Introduction]
This script is for connecting to the CSE VPN (to be more accurate, vpn3.cse.cuhk.edu.hk) on Ubuntu 14.04.

For the first time connecting to VPN, please run:

sudo ./install.sh

The script will check and install the following packages:

 - strongswan
 - xl2tpd
 - ppp
 - isc-dhcp-client

The script will then help you to set the required config files, and also the CSE ID and password.

For each computer, you need to run the script once only.

To connect to the VPN, please run:

sudo ./vpn_connect.sh

To disconnect from the VPN, please run:

sudo ./vpn_disconnect.sh


[Trouble-shooting]
The scripts are incompatible to the scripts for connecting to CUHK VPN provided by ITSC.

If you have installed those scripts previously, you may find that you cannot connect to either CUHK VPN or CSE VPN using this script.

In this case, please run

sudo rm /etc/ipsec.conf

and then run install.sh again.

If the scripts fail in step "Connect to the VPN server", or get frozen in step "Change default route to ppp0", please check that you have input the correct password, or simply reinstall the scripts.

If you find that you cannot access to the internet after using the scripts, you may try:

sudo ip route add default via __GATEWAY__ dev __DEVICE__

with __GATEWAY__ and __DEVICE__ be replaced by the gateway and device respectively, which could be found in the step "Get default device and gateway".

[Contact]
If you have any enquiries about the scripts (or simply wants to know more about them), please contact me at nnkken@yahoo.com.hk