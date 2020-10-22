resource "aws_security_group" "ec2" {
  name   = "ec2-maintainer-sg"
  vpc_id = aws_vpc.main.id
  ingress = [
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    }
  ]
  egress = [{
    description      = "Complete access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}

resource "aws_key_pair" "mykeys" {
  key_name   = "mykeys"
  public_key = file("mykeys.pub")
}

resource "aws_iam_role" "maintainer-ec2" {
  name               = "maintainer-ec2"
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "maintainer-ec2-permissions" {
  name        = "maintainer-ec2-permissions"
  path        = "/"
  description = "Policy for EC2 instances to access EFS"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets"
      ],
      "Resource": "${aws_efs_file_system.scratch.arn}"
  }   
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "maintainer-ec2-policy-attachment" {
  role       = aws_iam_role.maintainer-ec2.name
  policy_arn = aws_iam_policy.maintainer-ec2-permissions.arn
}


resource "aws_iam_instance_profile" "access-efs" {
  name = "ec2-access-efs"
  role = aws_iam_role.maintainer-ec2.name
}

# resource "aws_instance" "maintainer" {

#   ami                         = "ami-0cda377a1b884a1bc"
#   instance_type               = "t3.small"
#   key_name                    = "mykeys"
#   security_groups             = [aws_security_group.ec2.id]
#   subnet_id                   = aws_subnet.main.id
#   associate_public_ip_address = true
#   connection {
#     type        = "ssh"
#     private_key = file("./mykeys")
#     host        = aws_instance.maintainer.public_ip
#   }

#   iam_instance_profile = aws_iam_instance_profile.access-efs.name

# }

# # resource "aws_spot_instance_request" "maintainer" {
# #   ami                    = "ami-0cda377a1b884a1bc"
# #   spot_price             = "0.0034"
# #   instance_type          = "t3.small"
# #   spot_type              = "one-time"
# #   block_duration_minutes = "120"
# #   wait_for_fulfillment   = "true"
# #   key_name               = "mykeys"

# #   security_groups             = [aws_security_group.ec2.id]
# #   subnet_id                   = aws_subnet.main.id
# # }

# output "ec2_public_ip" {
#   value = aws_instance.maintainer.public_ip
# }

resource aws_instance "gpu" {
  ami                         = "ami-0faf7ae313dd51ccc"
  associate_public_ip_address = true
  availability_zone           = "ap-south-1c"
  cpu_core_count              = 2
  cpu_threads_per_core        = 2
  disable_api_termination     = false
  ebs_optimized               = true
  get_password_data           = false
  hibernation                 = false
  iam_instance_profile        = "ec2-access-efs"


  instance_type      = "g4dn.xlarge"
  ipv6_address_count = 0
  ipv6_addresses     = []
  key_name           = "mykeys"
  monitoring         = false

  security_groups   = []
  source_dest_check = true
  subnet_id         = "subnet-04e56476ab88f3c77"
  tenancy           = "default"
  volume_tags       = {}
  vpc_security_group_ids = [
    "sg-0af7ef765f357c3aa",
  ]

  tags = {
    Name = "ECS Container Instance"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 150
    volume_size           = 50
    volume_type           = "gp2"
  }

  timeouts {}
}