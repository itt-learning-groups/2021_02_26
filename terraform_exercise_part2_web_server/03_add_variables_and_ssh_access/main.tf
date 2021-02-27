provider "aws" {
    region = "us-west-2"
}

data "aws_ami" "linux2" {
  most_recent = true

  filter {
    name = "description"
    values = ["Amazon Linux 2 AMI*"]
  }

  filter {
    name = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "web-server" {

  name = "terraform-web-server"

  # We'll add an ingress rule to allow the admin to log in and do mainenance.
  # We want to restrict this access to our own home IP address or the company private network.
  # So we'll use a variable to allow this value to be supplied dynamically when we run `terrafor apply`
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_ip}/32"] # We're getting this value from our variables.tf file
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  key_name      = var.key_name # We're getting this value from our variables.tf file
  vpc_security_group_ids = [aws_security_group.web-server.id]

  user_data = <<-EOF
              #!/usr/bin/bash
              sudo su
              yum update -y
              yum install -y httpd
              systemctl start httpd.service
              systemctl enable httpd.service
              echo "Hello World from $(hostname -f)" > /var/www/html/index.html
              EOF
}
