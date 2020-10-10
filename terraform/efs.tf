resource "aws_efs_file_system" "scratch" {

}

resource "aws_efs_mount_target" "scratch" {
  file_system_id  = aws_efs_file_system.scratch.id
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "scratch" {
  file_system_id = aws_efs_file_system.scratch.id
}