provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-09c5e030f74651050"
  instance_type = "t2.micro"
}
