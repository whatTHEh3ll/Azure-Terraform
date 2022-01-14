#!/bin/bash

terraform apply -auto-approve \
&& sleep 120; ansible-playbook provision.yml 
