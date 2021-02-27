provider "aws" {
    region = "us-west-2"
}

# AMI name: /aws/service/ami-amazon-linux-latest/amzn2-ami-minimal-hvm-x86_64-ebs
# See the ami_list.json file and match the AMI vame to the AMI ID below.
# We'll hard-code the AMI ID for now. We'll get more sophisticated in stage 03.
resource "aws_instance" "my_ec2" {
  ami           = "ami-0a1ccc021b9016ec9"
  instance_type = "t3.micro"
}
