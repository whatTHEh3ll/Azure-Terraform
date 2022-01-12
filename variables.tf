variable "location" {}

variable "prefix" {
  type    = string
  default = "my"
}

#variable "ssh-source-address" {
  #type    = string
#}

variable "public_key_path" {
  type = string
  description = "The path to the public key used to connect to the instance"
}

variable "tags" {
  type = map

  default = {
    Environment = "spot"
    Dept        = "projects"
  }
}

variable "sku" {
  default = {
    westus2 = "18.04-LTS"
    eastus  = "18.04-LTS"
  }
}
