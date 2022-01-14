# Terraform AZURE Cloud Virtual  Mult Machines
## using terraform to provision Azure Virtual machines and spot instances as well. The terraform output 
will create a hosts.ini file for Ansible playbooks

##### Authenticate with Azure
```
az login --use-device-code

```

##### Create a rsa 4096 bit key and name it (for Azure)
```
ssh-keygen -t rsa -b 4096 -f Azure 

```

#### connect to remote vm with custom key, with Azure being custom key
```
ssh Azure@<public_ip> -i Azure
```

##### Connect with Mosh (after ssh configuration chnages)

```
mosh <username>@<public_ip> --ssh="ssh -p <port> -i <custom_key>"

# example

mosh linuxuser@12.34.56.78 --ssh="ssh -p 1234 -i myprivatesshkey"
```

##### The INVENTORY-CREATE.sh script 

##### then create a backend.tf file with the following content pupolate the values based on output of script and place in root directory of project

```
terraform {
  backend "azurerm" {
    resource_group_name = ""
    storage_account_name = ""
    container_name = ""
    access_key = ""
    key = ""
  }
}
```

#### create a terraform.tfvars file for single vm deployment
```
location       = "westus2"

prefix         = "spot"

ssh-source-address = "# get public ip curl ipinfo.io"

public_key_path = "path/to/ssh/public_key"

```

#### create a terraform.tfvars file for multiple deployment of vms with node count variable
```
node_location   = "East US 2"
public_key_path = "path/to/ssh/public_key"
node_count      = 3
```
##### regular terrform commands
```
terraform console
terraform fmt
terraform init
terraform init -reconfigure
terraform plan 

# formats plan to no color removes funny characters
terraform plan -no-color > tfplan.txt

terraform validate
terraform apply -auto-approve
terraform destroy -auto-approve

# output to formated json (jq needs to be installed) run after apply
terraform show -json | jq . > state.json

# target a specific terraform resource
terraform plan -target resource.name 
terraform apply -auto-approve

# show public ip with az cli and format to json
az network public-ip list | jq . > ip-addresses.json

```

##### use the command below to verify the spot instance is running

```
az vm list \
   -g spot-resources \
   --query '[].{Name:name, MaxPrice:billingProfile.maxPrice}' \
   --output table
```
# Ansible 

```
ansible -m setup all -i hosts.ini -u #some user
```

Ansible gather facts output to file

```
ansible -m setup all -i hosts.ini --tree out/ -u root
```

Ansible cmdb

```
ansible-cmdb -t html_fancy_split -p local_js=1 out/
```

Ansible Ping

```
ansible all -m ping -i ../../../Ansible-Inventory/localhosts 
```

run complete Ansible playbook with vault encryption and path to password file set path accordingly

```
ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt -i hosts -u root 
```

run ansible playbook with tags

```
ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --tags "tag1,tag2,etc" -i hosts -u root 

ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --tags "tag1,tag2,etc" -i ../../../Ansible-Inventory/hosts
```

run ansible start at a certain task
```
ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --start-at-task="This is the task name" -i hosts -u root

ansible-playbook provision.yml --vault-password-file=/home/$USER/ansible-PASSWORDS/MYPASSWORD.txt --start-at-task="This is the task name" 
```


