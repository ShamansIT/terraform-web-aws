variable "aws_region" {
  description = "AWS region to deploy the infrastructure"
  type        = string
  default     = "eu-west-1"
}

variable "my_ip_cidr" {
  description = "Personal IP address (in CIDR notation) allowed to SSH into web inst(expl. 203.0.113.10/32)"
  type        = string
  default     = "0.0.0.0/0"
}