output "Jenkins-Master-ExternalIP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Worker-ExternalIP" {
  value = {
    for instance in aws_instance.jenkins-worker :
    instance.id => instance.public_ip
  }
}

output "ALB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}