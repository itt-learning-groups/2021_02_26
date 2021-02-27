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

# In order to serve web traffic, we have to define a firewall that will allow incoming traffic on our HTTP port
resource "aws_security_group" "web-server" {
  name = "terraform-web-server"

  # Allow our web server to handle inbound HTTP traffic from any IP address (0.0.0.0/0) on port 80 (the default HTTP port)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" # (note that HTTP is a TCP protocol: It's TCP at layer 4, HTTP at layer 7)
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow the EC2 to send outbound traffic to any IP address via any protocol: the default AWS security group egress rule
  # (Note that we need to allow outbound traffic to serve responses, as well as to allow the server to download software,
  #   like packages from its yum repository.)
  egress {
    # this weird looking config opens all ports and protocols
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web-server.id] # specify the ID of the security group created above
}
