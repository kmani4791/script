data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.VPC_NAME]
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Tier = "Private"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "es" {
  name        = "${var.ES_DOMAIN_NAME}-sg"
  description = "SG for managed OpenSearchManaged"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ES_DOMAIN_NAME}"
  }
}

# resource "aws_iam_service_linked_role" "es" {
#   aws_service_name = "es.amazonaws.com"
# }

# https://github.com/cloudposse/terraform-aws-elasticsearch/blob/master/main.tf
resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.ES_DOMAIN_NAME
  elasticsearch_version = "6.8"

  cluster_config {
    instance_count = 3
    instance_type  = "t3.medium.elasticsearch"
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  vpc_options {
   # subnet_ids         = toset(data.aws_subnets.private_subnets.ids)
    subnet_ids = data.aws_subnet_ids.private_subnets.ids
    security_group_ids = [aws_security_group.es.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 150
  }

  # advanced_options = {
  #   "rest.action.multi.allow_explicit_index" = "true"
  # }

  # advanced_security_options {
  #   enabled                        = true
  #   internal_user_database_enabled = true

  #   master_user_options {
  #     master_user_name     = var.ES_MASTER_NAME
  #     master_user_password = var.ES_MASTER_PASSWORD
  #   }
  # }

  # node_to_node_encryption {
  #   enabled = true
  # }

  # encrypt_at_rest {
  #   enabled    = true
  #   kms_key_id = var.KMS_ENCRYPTION_KEY
  # }
 
  # domain_endpoint_options {
  #   enforce_https       = true
  #   tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  # }

  access_policies = <<-CONFIG
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "es:*",
              "Principal": "*",
              "Effect": "Allow",
              "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.ES_DOMAIN_NAME}/*"
          }
      ]
  }
  CONFIG

  # depends_on = [aws_iam_service_linked_role.es]
}
