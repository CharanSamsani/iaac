resource "aws_key_pair" "new_key_pair" {
  key_name = "IAAC"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "new_vpc" {
  tags = {
    Name = "vpc_1"
  }
  cidr_block = var.cidr
}

resource "aws_subnet" "new_subnet" {
  tags = {
    Name = "subnet_1"
  }
  vpc_id = aws_vpc.new_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true 
}

resource "aws_internet_gateway" "new_gateway" {
  tags = {
    Name = "internet_gateway_1"
  }
  vpc_id = aws_vpc.new_vpc.id
}

resource "aws_route_table" "new_rt" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_gateway.id
  }
}

resource "aws_route_table_association" "new_rta" {
  subnet_id = aws_subnet.new_subnet.id
  route_table_id = aws_route_table.new_rt.id
}

resource "aws_security_group" "new_sg" {
  vpc_id = aws_vpc.new_vpc.id
  name = "new_security_group"
  
  ingress = [
    {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
    {
        description = "SSH from VPC"
        from_port  = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
    {
        description = "SonarQube"
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
    ]

    egress = [ 
    {
        description = "outbounds"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
    ]
}

resource "aws_instance" "new_instance" {
  tags = {
    Name = "Instance_1"
  }
  ami = "ami-0a5ac53f63249fba0"
  instance_type = var.instance_type
  key_name = aws_key_pair.new_key_pair.key_name
  subnet_id = aws_subnet.new_subnet.id
  vpc_security_group_ids = [aws_security_group.new_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum upgrade -y
  sudo yum install httpd php git -y
  sudo systemctl enable httpd 
  sudo systemctl start httpd
  EOF
}

resource "aws_s3_bucket" "new_bucket" {
  bucket = "bucket_1"
  acl = "public-read"

  tags = {
    Name = "myS3bucket"
    Environment = "Production"
    Owner = "Charan"
  }
}

resource "aws_ebs_volume" "new_ebs" {
  availability_zone = "ap-south-1a"
  size = 1
  tags = {
    Name = "ebs_1"
  }
}

resource "aws_volume_attachment" "new_ebs_attach" {
  device_name = "/dev/sdf"
  volume_id = aws_ebs_volume.new_ebs.id
  instance_id = aws_instance.new_instance.id
  force_detach = true

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host = aws_instance.new_instance.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo mkfs -t ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /var/www/html",
      "sudo rm -rf /var/www/html*"
      "sudo git clone https://github.com/Charan-Samsani/test.git /var/www/html"
     ]
  }
}
