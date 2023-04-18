resource "aws_key_pair" "linux_key" {
  key_name   = "linux_key"
  public_key = file("./key/ssh_rsa_public_key.pub")
}

resource "aws_instance" "linux_ec2" {
  ami           = "ami-02b2e78e9b867ffec"
  instance_type = "t2.micro"

  key_name = aws_key_pair.linux_key.key_name

  tags = {
    Name = "Linux EC2"
  }
}

output "linux_public_ip" {
  value = aws_instance.linux_ec2.public_ip
}