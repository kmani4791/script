locals {
  public_subnets   = jsondecode(file("${path.module}/json/public_subnets.json"))
  web_subnets      = jsondecode(file("${path.module}/json/web_subnets.json"))
  app_subnets      = jsondecode(file("${path.module}/json/app_subnets.json"))
  data_subnets     = jsondecode(file("${path.module}/json/data_subnets.json"))
  client_subnets   = jsondecode(file("${path.module}/json/client_subnets.json"))
  public_subnet_rt = jsondecode(file("${path.module}/route-tables-json/public_subnet_rt.json"))
  # public_subnet_b = jsondecode(file("${path.module}/route-tables-json/public_subnet-2b-rt.json"))
  # public_subnet_c = jsondecode(file("${path.module}/route-tables-json/public_subnet-2c-rt.json"))
}

resource "aws_internet_gateway_attachment" "prod-vpc" {
  internet_gateway_id = aws_internet_gateway.prod-vpc.id
  vpc_id              = aws_vpc.prod-vpc.id
}

resource "aws_vpc" "prod-vpc" {
  cidr_block           = "10.151.0.0/16"
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  instance_tenancy     = "default"
}

resource "aws_internet_gateway" "prod-vpc" {}

####### Public Subnet ####

resource "aws_subnet" "prod-subnet-public-1" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = each.value.availability_zone
  tags = {
    Name = each.value.Subnet-Name
  }
}

#data "terraform_remote_state" "routes" {
#  backend "local" {
#    path = ./route-tables-json/public_subnet_rt.json
#  }
#  for_each = local.public_subnet_rt
#    config = {
#    contents = local.public_subnet_rt
#  }
#}

resource "aws_route_table" "public_rt" {
  for_each = local.public_subnets
  vpc_id   = aws_vpc.prod-vpc.id
  #route    = data.terraform_remote_state.routes[each.key].routes
  tags = {
    Name = each.value.rt-name
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  #count          = length(var.subnets_cidr)
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.prod-subnet-public-1[each.key].id
  route_table_id = aws_route_table.public_rt[each.key].id
}
resource "aws_network_acl" "Public-subnet" {
  for_each = local.public_subnets
  vpc_id   = aws_vpc.prod-vpc.id
  tags = {
    Name = each.value.Nacl-name
  }
}
resource "aws_network_acl_association" "public-nacl" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.prod-subnet-public-1[each.key].id
  network_acl_id = aws_network_acl.Public-subnet[each.key].id

}


#### Web-Subnets ### 
resource "aws_subnet" "prod-subnet-web" {
  for_each                = local.web_subnets
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone       = each.value.availability_zone
  tags = {
    Name = each.value.Subnet-Name
  }
}

resource "aws_route_table" "web-rt" {
  for_each = local.web_subnets
  vpc_id   = aws_vpc.prod-vpc.id

  tags = {
    Name = each.value.rt-name
  }
}

resource "aws_route_table_association" "web-subnet-association" {
  for_each       = local.web_subnets
  subnet_id      = aws_subnet.prod-subnet-web[each.key].id
  route_table_id = aws_route_table.web-rt[each.key].id
}

resource "aws_network_acl" "web-subnet-Nacl" {
  for_each = local.web_subnets
  vpc_id   = aws_vpc.prod-vpc.id
  tags = {
    Name = each.value.Nacl-name
  }
}
resource "aws_network_acl_association" "web-nacl" {
  for_each       = local.web_subnets
  subnet_id      = aws_subnet.prod-subnet-web[each.key].id
  network_acl_id = aws_network_acl.web-subnet-Nacl[each.key].id

}

####### App Subnet ###

resource "aws_subnet" "prod-subnet-app" {
  for_each                = local.app_subnets
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone       = each.value.availability_zone
  tags = {
    Name = each.value.Subnet-Name
  }
}

resource "aws_route_table" "app-rt" {
  for_each = local.app_subnets
  vpc_id   = aws_vpc.prod-vpc.id

  tags = {
    Name = each.value.rt-name
  }
}
resource "aws_route_table_association" "app-subnet-association" {
  for_each       = local.app_subnets
  subnet_id      = aws_subnet.prod-subnet-app[each.key].id
  route_table_id = aws_route_table.app-rt[each.key].id
}


resource "aws_network_acl" "app-subnet-Nacl" {
  for_each = local.app_subnets
  vpc_id   = aws_vpc.prod-vpc.id
  tags = {
    Name = each.value.Nacl-name
  }
}
resource "aws_network_acl_association" "app-nacl" {
  for_each       = local.app_subnets
  subnet_id      = aws_subnet.prod-subnet-app[each.key].id
  network_acl_id = aws_network_acl.app-subnet-Nacl[each.key].id

}
##### Data Subnet ###

resource "aws_subnet" "prod-subnet-data" {
  for_each                = local.data_subnets
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone       = each.value.availability_zone
  tags = {
    Name = each.value.Subnet-Name
  }
}

resource "aws_route_table" "data-rt" {
  for_each = local.data_subnets
  vpc_id   = aws_vpc.prod-vpc.id

  tags = {
    Name = each.value.rt-name
  }
}

resource "aws_route_table_association" "data-subnet-association" {
  for_each       = local.data_subnets
  subnet_id      = aws_subnet.prod-subnet-data[each.key].id
  route_table_id = aws_route_table.data-rt[each.key].id
}

resource "aws_network_acl" "data-subnet-Nacl" {
  for_each = local.data_subnets
  vpc_id   = aws_vpc.prod-vpc.id
  tags = {
    Name = each.value.Nacl-name
  }
}
resource "aws_network_acl_association" "data-nacl" {
  for_each       = local.data_subnets
  subnet_id      = aws_subnet.prod-subnet-data[each.key].id
  network_acl_id = aws_network_acl.data-subnet-Nacl[each.key].id

}

###### Client Subnet ####
resource "aws_subnet" "prod-subnet-client" {
  for_each                = local.client_subnets
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone       = each.value.availability_zone
  tags = {
    Name = each.value.Subnet-Name
  }
}

resource "aws_route_table" "prod-rt" {
  for_each = local.client_subnets
  vpc_id   = aws_vpc.prod-vpc.id

  tags = {
    Name = each.value.rt-name
  }
}

resource "aws_route_table_association" "client-subnet-association" {
  for_each       = local.client_subnets
  subnet_id      = aws_subnet.prod-subnet-client[each.key].id
  route_table_id = aws_route_table.prod-rt[each.key].id
}

resource "aws_network_acl" "client-subnet-Nacl" {
  for_each = local.client_subnets
  vpc_id   = aws_vpc.prod-vpc.id
  tags = {
    Name = each.value.Nacl-name
  }
}
resource "aws_network_acl_association" "client-nacl" {
  for_each       = local.client_subnets
  subnet_id      = aws_subnet.prod-subnet-client[each.key].id
  network_acl_id = aws_network_acl.client-subnet-Nacl[each.key].id

}