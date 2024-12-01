resource "aws_instance" "web_server" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.eip == null
  user_data                   = <<-EOF
    #!/bin/bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
  EOF

  tags = {
    Name = "cv-challenge02-server"
  }

}

resource "aws_eip_association" "eip_assoc" {
  instance_id         = aws_instance.web_server.id
  allow_reassociation = true
  allocation_id       = var.eip
}


resource "local_file" "ansible_inventory" {
  content  = <<-EOF
    [web_servers]
    ${var.eip != null ? aws_eip_association.eip_assoc.public_ip : aws_instance.web_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=devops_challenge.pem
  EOF
  filename = "${path.module}/inventory.ini"
  file_permission = 0644

  provisioner "local-exec" {
    command = <<-EOF
      aws ec2 wait instance-status-ok --instance-ids ${aws_instance.web_server.id}
      ssh-keygen -f "/home/dod/.ssh/known_hosts" -R "${var.eip != null ? aws_eip_association.eip_assoc.public_ip : aws_instance.web_server.public_ip} > /dev/null 2>&1"
      ansible-playbook -i inventory.ini  ansible/deploy.yml
    EOF 
  }
}
