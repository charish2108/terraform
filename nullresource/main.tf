#This Terraform Code Deploys Basic VPC Infra.
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

# terraform {
#   required_version = "<= 0.14" #Forcing which version of Terraform needs to be used
#   required_providers {
#     aws = {
#       version = "<= 3.0.0" #Forcing which version of plugin needs to be used.
#       source = "hashicorp/aws"
#     }
#   }
# }

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_name}"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags = {
        Name = "${var.IGW_name}"
    }
}

resource "aws_subnet" "subnets" {
    count = 3      #0,1,2
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${element(var.cidrs, count.index)}"
    availability_zone = "${element(var.azs, count.index)}"

    tags = {
        Name = "Public-Subnet-${count.index+1}"
    }
}

resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "${var.Main_Routing_Table}"
    }
}

resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.subnet1-public.id}"
    route_table_id = "${aws_route_table.terraform-public.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

data "aws_ami" "my_ami" {
     most_recent      = true
     #name_regex       = "^mavrick"
     owners           = ["721834156908"]
}


resource "aws_instance" "web-1" {
    count = 1
    #count = "${var.env == DEV ? 1 : 3}"
    #ami = "${data.aws_ami.my_ami.id}"
    ami = "${lookup(var.amis, var.aws_region, "us-east-1")}"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    key_name = "LaptopKey"   # .pemk ey
    subnet_id = "${element(aws_subnet.subnets.*.id, count.index)}"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true	
    tags = {
        Name = "Server-${count.index+1}"
        Env = "Prod"
        Owner = "Harish"
    }
}

resource "null_resource" "cluster" {
    provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
    connection {
        type = "ssh"
        user = "ec2-user"
        #password = "Sunshine@2108"
        private_key = "${file("LaptopKey.pem")}"  # provate key (.pem) should be in the same dir as mai.tf
        host = "${aws_instance.web-1.0.public_ip}"
    }
    }

    provisioner "remote-exec" {
    inline = [
        "chmod 700 /tmp/script.sh",
        "sudo ./tmp/script.sh",
        "sudo yum update -y",
        "sudo yum install nginx -y",
        "sudo service nginx start"
    ]
    connection {
        type = "ssh"
        user = "ec2-user"
        #password = "Sunshine@2108"
        private_key = "${file("LaptopKey.pem")}"  # provate key (.pem) should be in the same dir as mai.tf
        host = "${aws_instance.web-1.0.public_ip}"
    }
    }

    provisioner "local-exec" {
        command = <<EOH
            echo "${aws_instance.web-1.0.public_ip}" >> details && echo "${aws_instance.web-1.0.private_ip}"
        EOH
    }
}

# resource "aws_s3_bucket" "example" {
#     bucket = "s3bucketname"
#     lifecycle {
#         prevent_destroy = true
#     }
#     depends_on = ["aws_instance.web.1"]
# }

#output "ami_id" {
#  value = "${data.aws_ami.my_ami.id}"
#}
#!/bin/bash
# echo "Listing the files in the repo."
# ls -al
# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Running Packer Now...!!"
# packer build -var=aws_access_key=AAAAAAAAAAAAAAAAAA -var=aws_secret_key=BBBBBBBBBBBBB packer.json
#packer validate --var-file creds.json packer.json
#packer build --var-file creds.json packer.json
#packer.exe build --var-file creds.json -var=aws_access_key=AAAAAAAAAAAAAAAAAA -var=aws_secret_key=BBBBBBBBBBBBB packer.json
# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Running Terraform Now...!!"
# terraform init
# terraform apply --var-file terraform.tfvars -var="aws_access_key=AAAAAAAAAAAAAAAAAA" -var="aws_secret_key=BBBBBBBBBBBBB" --auto-approve
#https://discuss.devopscube.com/t/how-to-get-the-ami-id-after-a-packer-build/36