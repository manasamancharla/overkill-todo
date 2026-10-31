resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public-a"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-a"
  }
}

resource "aws_subnet" "public-b"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-b"
  }
}

resource "aws_subnet" "app-a"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.11.0/24"

  tags = {
    Name = "${var.project_name}-app-a"
  }
}

resource "aws_subnet" "app-b"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.12.0/24"

  tags = {
    Name = "${var.project_name}-app-b"
  }
}

resource "aws_subnet" "db-a"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.21.0/24"

  tags = {
    Name = "${var.project_name}-db-a"
  }
}

resource "aws_subnet" "db-b"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.22.0/24"

  tags = {
    Name = "${var.project_name}-db-b"
  }
}

resource "aws_subnet" "db-c"{
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block = "10.0.23.0/24"

  tags = {
    Name = "${var.project_name}-db-c"
  }
}
  
resource "aws_eip" "nat-a"{
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-a"
  }
}

resource "aws_eip" "nat-b"{
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-b"
  }
}

resource "aws_nat_gateway" "nat-a"{
  allocation_id = aws_eip.nat-a.id
  subnet_id     = aws_subnet.public-a.id

  tags = {
    Name = "${var.project_name}-nat-a"
  }
}

resource "aws_nat_gateway" "nat-b"{
  allocation_id = aws_eip.nat-b.id
  subnet_id     = aws_subnet.public-b.id

  tags = {
    Name = "${var.project_name}-nat-b"
  }
}

resource "aws_route_table" "public"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table" "private-a"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-a.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project_name}-rt-private-a"
  }
}

resource "aws_route_table" "private-b"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-b.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project_name}-rt-private-b"
  }
}

resource "aws_route_table_association" "public-1"{
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-a.id
}

resource "aws_route_table_association" "public-2"{
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-b.id
}

resource "aws_route_table_association" "private-1"{
  route_table_id = aws_route_table.private-a.id
  subnet_id      = aws_subnet.app-a.id
}

resource "aws_route_table_association" "private-2"{
  route_table_id = aws_route_table.private-b.id
  subnet_id      = aws_subnet.app-b.id
}

resource "aws_route_table_association" "private-3"{
  route_table_id = aws_route_table.private-a.id
  subnet_id      = aws_subnet.db-a.id
}

resource "aws_route_table_association" "private-4"{
  route_table_id = aws_route_table.private-b.id
  subnet_id      = aws_subnet.db-b.id
}  

# AZ-c shares NAT-a
resource "aws_route_table_association" "private-5"{
  route_table_id = aws_route_table.private-a.id
  subnet_id      = aws_subnet.db-c.id
}  