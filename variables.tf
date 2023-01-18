variable "region" {
  description = "AWS region"
  type        = string
}

variable "shared_credentials_file" {
  type        = list(string)
  description = "AWS credentials file path"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile"
}

variable "author" {
  type        = string
  description = "Created by"
}

variable "availability_zones" {
  type        = list(any)
  description = "List of Availability Zones"
}

# variable "public_key_path" {
#   type        = string
#   description = "SSH public key path"
# }

// Default values

variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "sandbox"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "sandbox"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.1.0.0/16"
}

variable "public_subnets_count" {
  type        = number
  description = "Number of public subnets"
  default     = 2
}

variable "private_subnets_count" {
  type        = number
  description = "Number of private subnets"
  default     = 2
}

# variable "bastion_instance_type" {
#   type        = string
#   description = "Bastion instance type"
#   default     = "t2.micro"
# }
