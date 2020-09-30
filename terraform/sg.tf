resource "aws_security_group" "simple" {
  name        = "videoc-1262"
  description = "2020-09-29T19:55:41.266Z"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
  ]

  tags   = {}
  vpc_id = aws_vpc.main.id

  timeouts {}
}

# aws_security_group_rule.simple:
resource "aws_security_group_rule" "simple" {
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  from_port         = 80
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
  protocol          = "tcp"
  security_group_id = aws_security_group.simple.id
  self              = false
  to_port           = 80
  type              = "ingress"
}

# aws_security_group_rule.simple-1:
resource "aws_security_group_rule" "simple-1" {
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  from_port         = 0
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
  protocol          = "-1"
  security_group_id = aws_security_group.simple.id
  self              = false
  to_port           = 0
  type              = "egress"
}