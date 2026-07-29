variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the AWS VPC"
  default     = "192.168.0.0/20"
}

variable "web_subnet_cidr" {
  type        = string
  description = "The CIDR block for the web subnet"
  default     = "192.168.1.0/24"
}

variable "app_subnet_cidr" {
  type        = string
  description = "The CIDR block for the app subnet"
  default     = "192.168.2.0/24"
}

variable "db_subnet_cidr" {
  type        = string
  description = "The CIDR block for the db subnet"
  default     = "192.168.3.0/24"
}

variable "mgmt_subnet_cidr" {
  type        = string
  description = "The CIDR block for the mgmt subnet"
  default     = "192.168.4.0/24"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone to deploy subnets in"
  default     = "us-east-1a"
}
