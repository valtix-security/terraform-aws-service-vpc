variable "access_key" {
  description = "customer access key"
}

variable "secret_key" {
  description = "customer secret key"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "zones" {
  description = "AZ names"
  default     = ["us-east-1a"]
}

variable "prefix" {
  description = "All the resource will be created with this prefix e.g: valtix_svpc"
  default     = "valtix_svc"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_subnet_bits" {
  description = "Number of additional bits in the subnet. The final subnet mask is the vpc_cidr mask + the value provided here"
  default     = 8
}