provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-be-111z"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-be-table"
  }
}

module "linux_ec2" {
  source = "./modules/linux_ec2"
}

module "windows_ec2" {
  source = "./modules/windows_ec2"
}

resource "null_resource" "ansible_provision" {
  depends_on = [
    module.linux_ec2,
    module.windows_ec2
  ]

  provisioner "local-exec" {
    command = "OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -i ./dynamic_inventory.py ansible/install-java.yml --ssh-common-args='-o StrictHostKeyChecking=no' --become -e 'ansible_winrm_operation_timeout_sec=100 ansible_winrm_read_timeout_sec=110'"
  }
}