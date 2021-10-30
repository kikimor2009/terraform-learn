output ec2_public_ip {
  value       = module.webserver-instance.instance.public_ip
}