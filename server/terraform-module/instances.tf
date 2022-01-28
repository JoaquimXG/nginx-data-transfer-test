resource aws_instance server {
  ami           = data.aws_ami.ubuntu.id
  key_name = var.key_name
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  availability_zone = var.az

  vpc_security_group_ids = var.security_group_id == null ? [aws_security_group.sg.id] : [var.security_group_id]
  
  provisioner remote-exec {
    inline = ["# Connected!"]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.priv_key_path)
      host = self.public_ip
    }
  }
  
  provisioner local-exec {
    command = "ansible-playbook -i ${self.public_ip}, -u ubuntu --private-key ${var.priv_key_path} ${var.playbook_path}" 
  }

  tags = {
    Name    = var.tag_name
  }
}