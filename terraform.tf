terraform {
  cloud {
    organization = "my-terraform-playground"
    workspaces {
      name = "openvpn-3sites-connect"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}