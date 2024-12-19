# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                 = "default"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "t2micro_ec2" {
  ami = "ami-0742b4e673072066f"
  subnet_id = "subnet-0a5b8034e80e31b06"
  instance_type = "t2.micro"
  tags = {
    name = "Udacity T2"
  }
  count = "4"
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "m4large_ec2" {
  ami = "ami-0742b4e673072066f"
  instance_type = "m4.large"
  subnet_id = "subnet-0a5b8034e80e31b06"
  tags = {
    name = "Udacity M4"
  }
  count = "2"
}
