provider "aws" {
    region = "us-west-2"
}

# If we don't want to hard-code the AMI ID, we don't have to. We can AWS to supply it.
data "aws_ami" "linux2" {
  # We'll always get the most recent version this way.
  most_recent = true

  # We want an Amazon "Linux2" AMI
  filter {
    name = "description"
    values = ["Amazon Linux 2 AMI*"]
  }

  # We want an AMI that's available
  filter {
    name = "state"
    values = ["available"]
  }

  # We'll choose hvm
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Note that we have to use "amazon" here because this is an Amazon AMI.
  # We can create our own AMIs, but that's not where this one came from.
  owners = ["amazon"] 
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.linux2.id # specify the ID of the AMI found from the query above
  instance_type = "t3.micro"
}
