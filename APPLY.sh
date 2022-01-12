#!/bin/bash

terraform apply -auto-approve \
&& sleep 180; ansible-playbook provision.yml --vault-password-file=/home/coney/ansible-PASSWORDS/MASTER.txt -i hosts.ini -u azure \
&& ansible-playbook post-install.yml -i hosts.ini -u root