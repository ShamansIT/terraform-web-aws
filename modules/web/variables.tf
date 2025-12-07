variable "subnet_ids" {
  description = "List of subnet IDs where web instances will be placed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups to attach to web instances"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for web instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for web instances"
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "User data script for bootstrapping web instances"
  type        = string
}

variable "tags" {
  description = "Common tags for web instances"
  type        = map(string)
  default     = {}
}
