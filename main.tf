provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a VPC
resource "aws_vpc" "jab" {
   cidr_block  = var.vpc_cidr_block

   tags = {
       Name = "jab-vpc"
   }
}
#create a SUBNET

resource "aws_subnet" "jab-pub" {
    vpc_id  = "${aws_vpc.jab.id}"
    cidr_block = var.pub_subnet_cidr_block

    tags = {
        Name = "jab-subnet"
    }
}

#create a SUBNET

resource "aws_subnet" "jab-priv" {
    vpc_id  = "${aws_vpc.jab.id}"
    cidr_block = var.priv_subnet_cidr_block

    tags = {
        Name = "jab-subnet-priv"
    }
}

#create a Internet gateway

resource "aws_internet_gateway" "jab-gw" {
    vpc_id  = "${aws_vpc.jab.id}"
    tags = {
        Name = "jab-gw"
    }
}

#create a route table

resource "aws_route_table" "jab-pub-rt" {
    vpc_id  = "${aws_vpc.jab.id}"

    route {
        cidr_block = var.pub_rt_table_cidr_block
        gateway_id = "${aws_internet_gateway.jab-gw.id}"
    }
    tags = {
        Name = "jab-gw"
    }
}
#create a route table subnet association

resource "aws_route_table_association" "jab-rts" {
    subnet_id = aws_subnet.jab-pub.id
    route_table_id = aws_route_table.jab-pub-rt.id
}
#create a eip[elastic IP]

resource "aws_eip" "jab-eip" {
    vpc = true

    tags = {
        Name = "jab-eip"
    }
}
#create a NAT gateway

resource "aws_nat_gateway" "jab-ngw" {
    allocation_id = "${aws_eip.jab-eip.id}"
    subnet_id     = "${aws_subnet.jab-pub.id}"
    tags = {
        Name = "jab-ngw"
    }
}
resource "aws_security_group" "jab-sec-grp" {
    name          = "jab-sec-grp"
    description   = "sec-grp"
    vpc_id        = "${aws_vpc.jab.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["99.0.85.90/32"]
        
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
    "type" = "jab-security-group"
    }
}
#create an instance

resource "aws_instance" "jab-ec2-instance" {
  ami           = "${lookup(var.ami,var.aws_region)}"  
  #ami = "ami-09d95fab7fff3776c"
  count         = "${var.instance_count}"
  #count = 1
  instance_type = "${var.instance_type}"
  #instance_type = "t2.micro"
  subnet_id = "${aws_subnet.jab-pub.id}"
  vpc_security_group_ids = ["${aws_security_group.jab-sec-grp.id}"]
  associate_public_ip_address = true

  #create a elastic block storage[volume]
  ebs_block_device {
      #device_name = "/dev/xvda"
      device_name = var.device_name
      #volume_size = 10
      volume_size = var.volume_size
      encrypted = true
  }
    tags = {
    Name = "HelloWorld"
  }
}

#create a S3 bucket [simple storage service]

resource "aws_s3_bucket" "jabbucket" {
    #bucket = "jabbucket"
    bucket  = var.bucket
    acl     = "private"

    versioning {
     enabled = var.versioning_enabled
    }
    tags = {
        Name = "jabbucket"
    }
}
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${aws_subnet.jab-pub.id}", "${aws_subnet.jab-priv.id}"]

  tags = {
    Name = "jab_subnet_group"
  }
}

resource "aws_db_instance" "jab-db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "jabjab"
  password             = "jab123456"
  #parameter_group_name = "default.mysql5.7.22"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
}
resource "aws_lb" "jab-loadbalancer" {
  name               = "jab-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.jab-pub.id}"]

  enable_deletion_protection = true

  tags = {
    Environment = "dev"
  }
}













    

