provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "public_web_subnet_az1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Web-Subnet-AZ-1"
  }
}

resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-App-Subnet-AZ-1"
  }
}

resource "aws_subnet" "private_db_subnet_az1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-DB-Subnet-AZ-1"
  }
}

resource "aws_subnet" "public_web_subnet_az2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Web-Subnet-AZ-2"
  }
}

resource "aws_subnet" "private_app_subnet_az2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-App-Subnet-AZ-2"
  }
}

resource "aws_subnet" "private_db_subnet_az2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-DB-Subnet-AZ-2"
  }
}
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for the web tier"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for the application tier"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security group for the database tier"
  vpc_id      = aws_vpc.my_vpc.id
}
resource "aws_network_acl" "web_acl" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [
    aws_subnet.public_web_subnet_az1.id,
    aws_subnet.public_web_subnet_az2.id,
  ]
  egress {
    rule_no   = 100
    action    = "allow"
    cidr_block = "0.0.0.0/0"
    protocol  = -1
    from_port = 0
    to_port   = 0
  }
}

resource "aws_network_acl" "app_acl" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [
    aws_subnet.private_app_subnet_az1.id,
    aws_subnet.private_app_subnet_az2.id,
  ]
  egress {
    rule_no   = 100
    action    = "allow"
    cidr_block = "0.0.0.0/0"
    protocol  = -1
    from_port = 0
    to_port   = 0
  }
}

resource "aws_network_acl" "db_acl" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [
    aws_subnet.private_db_subnet_az1.id,
    aws_subnet.private_db_subnet_az2.id,
  ]
  egress {
    rule_no   = 100
    action    = "allow"
    cidr_block = "0.0.0.0/0"
    protocol  = -1
    from_port = 0
    to_port   = 0
  }
}
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_instance.nat_ip_az1.allocation_id
  subnet_id     = aws_subnet.public_web_subnet_az1.id
}

resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_instance.nat_ip_az2.allocation_id
  subnet_id     = aws_subnet.public_web_subnet_az2.id
}

resource "aws_instance" "nat_ip_az1" {
  ami           = "ami-0a3c3a20c09d6f377"
  instance_type = "t2.micro"
  key_name      = "tf"
  subnet_id     = aws_subnet.public_web_subnet_az1.id
}

resource "aws_instance" "nat_ip_az2" {
  ami           = "ami-0a3c3a20c09d6f377"
  instance_type = "t2.micro"
  key_name      = "tf"
  subnet_id     = aws_subnet.public_web_subnet_az2.id
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_db_subnet_az1.id, aws_subnet.private_db_subnet_az2.id]
}

resource "aws_rds_cluster" "my_cluster" {
  cluster_identifier           = "my-cluster"
  engine                       = "aurora-mysql"
  master_username              = "admin"
  master_password              = "password"
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.db_sg.id]
  skip_final_snapshot          = true
  final_snapshot_identifier    = "my-final-snapshot"
  db_cluster_parameter_group_name = "default.aurora-mysql5.7"
}

resource "aws_rds_cluster_instance" "my_cluster_instance" {
  count                = 2
  identifier           = "my-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.my_cluster.id
  instance_class       = "db.t2.micro"
  engine               = "aurora-mysql"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
}
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [
    aws_subnet.public_web_subnet_az1.id,
    aws_subnet.public_web_subnet_az2.id,
  ]
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = [
    aws_subnet.private_app_subnet_az1.id,
    aws_subnet.private_app_subnet_az2.id,
  ]
}