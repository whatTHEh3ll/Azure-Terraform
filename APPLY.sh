#!/bin/bash

terraform apply -auto-approve \
# create hosts.ini file
&& touch hosts.ini \
# get public ip address
&& terraform output public_ip_address > hosts.ini 
# remove specail characters from terraform output
sed -i 's/[]\[",]//g' hosts.ini 
# remove horizontal white space
sed -i 's/ //g' hosts.ini 
# eappend group vars to host.ini
echo [all:vars] >> hosts.ini 
echo ansible_python_interpreter=/usr/bin/python3 >> hosts.ini 
# prepend hostgroup name to hosts.ini
sed -i '0,/^/s//[Azure]/' hosts.ini 

