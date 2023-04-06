# VPC

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Subnets
resource "aws_subnet" "public" {
  count = var.public_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = var.private_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${count.index}"
  }
}

resource "aws_subnet" "database" {
  count = var.database_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.${count.index + 20}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-database-${count.index}"
  }
}

# Gateways
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.private_subnets
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.private[count.index].id

  tags = {
    Name = "${var.vpc_name}-nat-${count.index}"
  }
}


# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = 0.0.0.0/0
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  count = var.private_subnets
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}


# Route table associations

resource "aws_route_table_association" "public" {
  count = var.public_subnets
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = var.private_subnets
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# EIPs
resource "aws_eip" "nat" {
  count = var.private_subnets
  vpc = true

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index}"
  }
}

# Security groups
resource "aws_security_group" "public" {
  name = "${var.vpc_name}-public-sg"
  description = "Allow inbound traffic to the public subnet"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["