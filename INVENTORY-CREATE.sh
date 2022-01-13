#!/bin/bash
mv hosts.tsv hosts.ini 
# prepend blank linebreak with sed
sed -i '1s/^/\n/' hosts.ini 
# append varaibles to hosts.ini
echo -e "\n[all:vars]" >> hosts.ini 
echo ansible_python_interpreter=/usr/bin/python3 >> hosts.ini
# prepend hostgroup name to hosts.ini with sed 
sed -i '0,/^/s//[Azure]/' hosts.ini 


