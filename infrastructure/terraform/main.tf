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

  inbound_rule { # SSH
    protocol         = "tcp"
    source_addresses = ["0.0.0.0/0", "::/0"]
    port_range       = "22"
  }

  outbound_rule {
    # https://tailscale.com/kb/1082/firewall-ports: 
    # > Let your internal devices start UDP from :41641 to *:*.
    # > Direct WireGuard tunnels use UDP with source port 41641. 
    # > We recommend *:* because you cannot possibly predict every guest Wi-fi, coffee shop, LTE 
    # > provider, or hotel network that your users may be using.
    protocol              = "udp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    port_range            = "1-65535"
  }

  outbound_rule { # Tailscale's STUN server.
    # See https://tailscale.com/kb/1082/firewall-ports for more details.
    protocol              = "udp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    port_range            = "3478"
  }

  outbound_rule { # Upstream DNS
    protocol              = "udp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    port_range            = "53"
  }

  outbound_rule { # Upstream DNS
    protocol              = "tcp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    port_range            = "53"
  }

  outbound_rule { # HTTP
    protocol              = "tcp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    port_range            = "80"
  }

  outbound_rule { # HTTPS
    protocol              = "tcp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    port_range            = "443"
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
