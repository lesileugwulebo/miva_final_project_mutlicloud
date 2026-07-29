resource "aws_vpc" "hub" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "multicloud-hub-vpc"
  }
}

resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.web_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "web-tier-subnet"
  }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.app_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "app-tier-subnet"
  }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.db_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "db-tier-subnet"
  }
}

resource "aws_subnet" "mgmt" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = var.mgmt_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "mgmt-tier-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hub.id
  tags = {
    Name = "hub-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hub.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "web_assoc" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.hub.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_assoc" {
  subnet_id      = aws_subnet.db.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "mgmt_assoc" {
  subnet_id      = aws_subnet.mgmt.id
  route_table_id = aws_route_table.private.id
}
