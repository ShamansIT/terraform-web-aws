output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "web_public_ips" {
  description = "Public IPs of web instances"
  value       = module.web.public_ips
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}
