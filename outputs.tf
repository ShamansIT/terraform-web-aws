# outputs.tf
#
# Terraform outputs

output "web_a_public_ip" {
  description = "Public IP of web instance A"
  value       = aws_instance.web_a.public_ip
}

output "web_b_public_ip" {
  description = "Public IP of web instance B"
  value       = aws_instance.web_b.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}
