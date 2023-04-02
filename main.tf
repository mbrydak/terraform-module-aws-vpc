resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = var.public_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "private" {
  count = var.private_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "database" {
  count = var.database_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.${count.index + 20}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}