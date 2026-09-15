output "server_ipv4" {
  description = "Public IPv4 address of the web server -- point the domain's A record here"
  value       = hcloud_server.web.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address of the web server -- point the domain's AAAA record here"
  value       = hcloud_server.web.ipv6_address
}

output "server_name" {
  value = hcloud_server.web.name
}
