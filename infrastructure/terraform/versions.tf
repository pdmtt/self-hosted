terraform {
  required_version = "~> 1.13"

  backend "s3" {
    region       = "us-east-1"
    bucket       = "self-hosted-terraform-backend"
    key          = "terraform.tfstate"
    use_lockfile = true
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.67"
    }

    ansible = {
      // See https://blog.sneakybugs.com/ansible-inventory-terraform/
      source  = "ansible/ansible"
      version = "~> 1.3"
    }
  }
}

