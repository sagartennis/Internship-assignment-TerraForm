# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  
}

# Create a VPC
resource "aws_vpc" "Main" {
  cidr_block = "10.0.0.0/16"
}

# Configure Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.Main.id
}

# Configure Public Subnet-1 in AZ 1
resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
}

# Configure Public Subnet-2 in AZ 2
resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2b"
}

# Configure Private Subnet-1 in AZ 1
resource "aws_subnet" "PrivateSubnet1" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
}

# Configure Private Subnet-2 in AZ 2
resource "aws_subnet" "PrivateSubnet2" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2b"
}

# Configure NatGateway
resource "aws_nat_gateway" "NatGW" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.PublicSubnet1.id
}

resource "aws_eip" "eip" {
  
  vpc      = true
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.Main.id
}

resource "aws_route_table_association" "PublicRouteTableAssociation1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "PublicRouteTableAssociation2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route" "PublicRoute" {
  route_table_id            = aws_route_table.PublicRouteTable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                =  aws_internet_gateway.gw.id
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.Main.id
}

resource "aws_route_table_association" "PrivateRouteTableAssociation1" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route_table_association" "PrivateRouteTableAssociation2" {
  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route" "PrivateRoute" {
  route_table_id            = aws_route_table.PrivateRouteTable.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            =  aws_nat_gateway.NatGW.id
}

resource "aws_security_group" "PublicSecGroup" {
  name        = "PublicSecGroup"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

}

resource "aws_security_group" "PrivateSecGroup" {
  name        = "PrivateSecGroup"
  description = "PrivateSecGroup "
  vpc_id      = aws_vpc.Main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  
}

resource "aws_security_group" "LBGroup" {
  name        = "LBGroup"
  description = "LB Sec Group"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

}

resource "aws_instance" "EC2Public" {
  ami           = "ami-0cf6f5c8a62fa5da6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.PublicSubnet1.id
  availability_zone = "us-west-2a"
  security_groups = [aws_security_group.PublicSecGroup.id]
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volume.id
  instance_id = aws_instance.EC2Public.id
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "us-west-2a"
  size              = 10
}

resource "aws_instance" "EC2Private" {
  ami           = "ami-0cf6f5c8a62fa5da6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.PrivateSubnet1.id
  availability_zone = "us-west-2a"
  security_groups = [aws_security_group.PrivateSecGroup.id]
}

resource "aws_volume_attachment" "ebs_att2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volume2.id
  instance_id = aws_instance.EC2Private.id
}

resource "aws_ebs_volume" "volume2" {
  availability_zone = "us-west-2a"
  size              = 10
}

# Create a new load balancer
resource "aws_elb" "LB" {
  name               = "LB"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 8
    target              = "HTTP:80/"
    interval            = 10
    
  }
}

output "VPC_public_ip" {
   value = aws_vpc.Main.id
 }

output "VPC_Public_Subnet1" {
   value = aws_subnet.PublicSubnet1.id
 }

output "VPC_Public_Subnet2" {
   value = aws_subnet.PublicSubnet2.id
 }

output "VPC_Private_Subnet1" {
   value = aws_subnet.PrivateSubnet1.id
 }

output "VPC_Private_Subnet2" {
   value = aws_subnet.PrivateSubnet2.id
 }

output "Public_Route_Table" {
   value = aws_route_table.PublicRouteTable.id
 }

output "Private_Route_Table" {
   value = aws_route_table.PrivateRouteTable.id
 }
