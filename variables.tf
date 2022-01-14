variable "node_location" {
  type = string
}

variable "node_address_space" {
  default = ["10.0.0.0/16"]
}

#variable for network range

variable "node_address_prefixes" {
  default = ["10.0.0.0/16"]
}

variable "node_count" {
  type = number
}

variable "public_key_path" {
  type        = string
  description = "The path to the public key used to connect to the instance"
}

variable "private_key_path" {
  type        =  string
  description = "The path to the private key used to connect to the instance"
}