resource "aws_key_pair" "windows_key" {
  key_name   = "windows_key"
  public_key = file("./key/testvm.pem")
}

resource "aws_instance" "windows_ec2" {
  ami           = "ami-0e42bfd2029a917a4"
  instance_type = "t2.micro"

  key_name = aws_key_pair.windows_key.key_name

  # Add user_data to run the PowerShell script
  user_data = base64encode(file("${path.module}/winrm_config.ps1"))

  tags = {
    Name = "Windows EC2"
  }
}

output "windows_public_ip" {
  value = aws_instance.windows_ec2.public_ip
}