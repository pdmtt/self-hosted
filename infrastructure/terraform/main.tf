resource "digitalocean_ssh_key" "repository" {
  name       = "repositoryKey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "server" {
  name   = "main"
  image  = "ubuntu-24-04-x64"
  size   = "s-2vcpu-4gb"
  region = "SFO3" # san francisco

  ssh_keys = [digitalocean_ssh_key.repository.fingerprint]
}

resource "ansible_group" "server" {
  name = "server"
}

resource "ansible_host" "server" {
  name   = "server"
  groups = [ansible_group.server.name]
  variables = {
    ansible_host = digitalocean_droplet.server.ipv4_address
  }
}
