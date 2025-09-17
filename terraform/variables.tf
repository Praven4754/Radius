variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "radius"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 25
}

variable "ubuntu_owner_id" {
  description = "Canonical (Ubuntu) AWS account ID"
  type        = string
  default     = "099720109477"
}

variable "ubuntu_version_filter" {
  description = "Filter for Ubuntu AMI"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "allowed_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
  default     = [8443, 8084, 80, 3001, 22, 443, 9090, 8083]
}
