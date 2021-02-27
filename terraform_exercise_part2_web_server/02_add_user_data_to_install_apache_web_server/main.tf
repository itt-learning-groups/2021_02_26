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
  vpc_security_group_ids = [aws_security_group.web-server.id]

  # The user-data will be run when our instance starts up. It installs a basic Apache web server
  #   and an index.html that will print a "Hello world" message
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
