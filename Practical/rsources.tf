resource "aws_instance" "ec2demo" {
  ami             = "ami-068e0f1a600cd311c"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.TF_SG.id}"]
  subnet_id       = aws_subnet.PublicSubnet.id
  associate_public_ip_address = true
  user_data       = <<-EOF
    #!/bin/bash
    sudo yum install -y httpd
    echo "sammek gandhi" | sudo tee /var/www/html/index.html
    sudo systemctl enable --now httpd
    EOF

  tags = {
    "Name" = "Terraform EC2"
  }
}

#Elastic IP
resource "aws_eip" "my_eip" {
  instance = aws_instance.ec2demo.id
  depends_on = [ aws_internet_gateway.myIgw ]  
}

#Key_pair

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}


#securitygroup using Terraform

resource "aws_security_group" "TF_SG" {
  name        = "security group using Terraform"
  description = "security group using Terraform"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description      = "HTTPS"  
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "TF_SG"
  }
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  tags = {
    Name = "myvpc"
  }
}

# Create a public subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = "ap-south-1a"
  cidr_block        = "10.0.1.0/24"
}

# create a private subnet
resource "aws_subnet" "PrivSubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

}


# create IGW
resource "aws_internet_gateway" "myIgw" {
  vpc_id = aws_vpc.myvpc.id
}

# route Tables for public subnet
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIgw.id
  }
}


# route table association public subnet 
resource "aws_route_table_association" "PublicRTAssociation" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}
