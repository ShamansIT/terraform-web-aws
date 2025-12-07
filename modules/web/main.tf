resource "aws_instance" "web" {
  count = length(var.subnet_ids)

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = var.user_data
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${lookup(var.tags, "Project", "terraform")}-web-${count.index + 1}"
      Role = "web"
    }
  )
}
