#provider "aws" {
#  region = var.region

#  default_tags {
#    tags = {
#      Project   = "CI-VPC-DR"
#      Team      = "creditsights-systems"
#      ManagedBy = "terraform"
#    }
#  }
#}
provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Project   = "CI-VPC-DR"
      Team      = "creditsights-systems"
      ManagedBy = "terraform"
    }
  }
}