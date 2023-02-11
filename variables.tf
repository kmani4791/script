
#variable "vpc-name" {
#  type = string
#  description = "ID element. Usually the component or solution name"
#}

variable "region" {
  type        = string
  description = "ID element. Usually the component or solution name"
}

#variable "availability_zone" {
#  type = string

#}

variable "AWS_REGION" {
  default = "us-west-2"
}

variable "subnets_cidr" {
  default = "null"
}

variable "routes" {
  type = list(object({
    subnet_name = string
    destination_cidr_block = string
    gateway_id = string
    network_interface_id = string
    instance_id = string
    vpc_peering_connection_id = string
  }))  
  default = []
}