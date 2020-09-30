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