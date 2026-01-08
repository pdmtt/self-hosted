# TLS certificate

## Justification

A TLS certificate is needed because:

> Connections between Tailscale nodes are secured with end-to-end encryption. Browsers, web APIs, 
> and products like Visual Studio Code are not aware of that, however, and can warn users or disable 
> features based on the fact that HTTP URLs to your tailnet services look unencrypted since they're 
> not using TLS certificates, which is what those tools are expecting.
> (https://tailscale.com/kb/1153/enabling-https)

## Requirements for the solution
- MUST allow certified subdomains because of the 
"[subfolder problem](https://caddy.community/t/the-subfolder-problem-or-why-cant-i-reverse-proxy-my-app-into-a-subfolder/8575)"
- SHOULD allow certificate auto-renewal to minimize maintenance overhead.

## Alternatives considered

### Tailscale's automatically generated device FQDN and certificate generation
[Tailscale uses MagicDNS to automatically provide a FQDN for each device in the tailnet](https://tailscale.com/kb/1217/tailnet-name)
and makes it easy to obtain a certificate for this FQDN (`tailscale cert <domain>`), but it doesn't 
allow subdomains, i.e. `device.tailnetname.ts.net` is possible, but `dozzle.device.tailnetname.ts.net` 
is not.

**Considering subdomains are a MUST, this option was discarded.**

### Manual custom domain records in a DNS provider + Caddy's "Automatic HTTPS"
It is possible to obtain a custom domain name and use e.g. AWS Route53 as its name server, which 
allows for subdomains. This demands an one-off effort to buy the domain and set the DNS records up.

[Caddy can automatically obtain and renew certificates using the ACME protocol](https://caddyserver.com/docs/automatic-https), 
featuring automatic ACME challenge resolution.
All ACME challenges require either port `80` or `443` to be publicly accessible, except the DNS one.
On one hand, allowing outbound traffic into either port could pose a security risk. On the other hand,
setting up Caddy to solve the DNS challenge would add complexity to the setup, because:
- its image would have to be custom built in order to compile it with the adequate plugin, which 
implies either trusting a non-official third-party image (potential security risk) or building it 
from scratch using a custom Dockerfile (extra effort)
- a AWS key would have to be created and available to the container running Caddy

To allow Caddy to solve HTTP challenges, port `80` must be publicly accessible and each (sub)domain
record must point to the server's public IP address. If they point to the server's public IP address,
port `443` would also need to be publicly accessible, because we won't be using Tailscale's network
interface anymore.