variable "vpc_id" {
  description = "VPC ID where ALB and target group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups for the ALB"
  type        = list(string)
}

variable "target_instance_ids" {
  description = "Instance IDs to register in the target group"
  type        = list(string)
}

variable "target_port" {
  description = "Port on which targets listen (e.g. 80)"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Common tags for ALB resources"
  type        = map(string)
  default     = {}
}
