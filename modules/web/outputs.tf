output "instance_ids" {
  description = "IDs of web instances"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Public IPs of web instances"
  value       = aws_instance.web[*].public_ip
}
