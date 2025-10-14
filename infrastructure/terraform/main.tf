resource "digitalocean_ssh_key" "repository" {
  name       = "repositoryKey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "server" {
  name   = "main"
  image  = "ubuntu-24-04-x64"
  size   = "s-2vcpu-4gb"
  region = "SFO3" # San Francisco

  ssh_keys = [digitalocean_ssh_key.repository.fingerprint]
}

# Sets up a firewall directly on DigitalOcean. This prevents that misconfigured firewall rules on 
# the server itself would allow unwanted access to it, such as when using docker with ufw.
resource "digitalocean_firewall" "main" {
  name        = "main"
  droplet_ids = [digitalocean_droplet.server.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22" # SSH
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53" # DNS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53" # DNS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80" # HTTP
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443" # HTTPS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

}

resource "ansible_group" "server" {
  name = "servers"
  variables = {
    ansible_ssh_user = "user"
  }
}

resource "ansible_host" "main" {
  name   = "main"
  groups = [ansible_group.server.name]
  variables = {
    ansible_host = digitalocean_droplet.server.ipv4_address
  }
}
