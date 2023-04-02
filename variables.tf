variable "vpc_name" {
  description = "Name of the VPC"
  default = "my-vpc"
}
variable "public_subnets" {
  description = "Number of public subnets to create"
  default = 3
}

variable "private_subnets" {
  description = "Number of private subnets to create"
  default = 3
}

variable "database_subnets" {
  description = "Number of database subnets to create"
  default = 3
}