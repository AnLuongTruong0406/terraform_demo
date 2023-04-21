#!/usr/bin/env python3

import boto3
import json

def get_ec2_instances():
    ec2 = boto3.resource('ec2', region_name='ap-southeast-1')
    instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    
    return instances

def create_inventory(instances):
    inventory = {
        "linux": {
            "hosts": [],
            "vars": {
                "ansible_user": "ec2-user",
                "ansible_ssh_private_key_file": "./key/private_key.pem"
            }
        },
        "windows": {
            "hosts": [],
            "vars": {
                "ansible_user": "Administrator",
                "ansible_password": "<mypassword>",
                "ansible_connection": "winrm",
                "ansible_winrm_transport": "basic",
                "ansible_winrm_scheme": "http",
                "ansible_port": "5985"
            }
        },
        "_meta": {
            "hostvars": {}
        }
    }

    for instance in instances:
        instance_name = instance.tags[0]['Value']
        instance_ip = instance.public_ip_address

        if "Linux" in instance_name:
            inventory["linux"]["hosts"].append(instance_ip)
        elif "Windows" in instance_name:
            inventory["windows"]["hosts"].append(instance_ip)
    
    return inventory

def main():
    instances = get_ec2_instances()
    inventory = create_inventory(instances)

    print(json.dumps(inventory, indent=2))

if __name__ == "__main__":
    main()
