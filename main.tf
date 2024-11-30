resource "aws_instance" "app_server" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.eip == null
  user_data                   = <<-EOF
    #!/bin/bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
  EOF

  tags = {
    Name = "cv-challenge02-server"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id         = aws_instance.app_server.id
  allow_reassociation = true
  allocation_id       = var.eip
}

