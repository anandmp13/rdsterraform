provider "aws" {
  access_key = "AKIAJHXONKWTWDAEGW5A"
  secret_key = "CM+5s3rfywQvMLtvpW+gCUYOt2gNqZvKfIlh88bk"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
