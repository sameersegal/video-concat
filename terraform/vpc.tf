resource "aws_vpc" "main" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "172.31.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags                             = {}
}

resource "aws_subnet" "main" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "ap-south-1c"
  cidr_block                      = "172.31.16.0/20"
  map_public_ip_on_launch         = true
  tags                            = {}
  vpc_id                          = aws_vpc.main.id

  timeouts {}
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}