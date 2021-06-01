# Internship-assignment-TerraForm


## PROBLEM ##

Create below setup using Hashicorp Terraform:
- One VPC with name 'main'
- Two Availability Zones
- Two Public Subnets and Two Private Subnets
- One EC2 instance in Public subnet
- One EC2 server in Private subnet
- EC2 in public subnet should be accessible by anybody outside
- EC2 in private subnet should be accessible only by EC2 instance in public subnet or any instances in public subnet
If this setup requires you to create any other AWS resources which are not mentioned above, please create them accordingly.

## ANSWER ## 

The Main.tf file contains all the network and resources added for the buidling the Infrastructure.
## NETWORK INFRA ##
## VPC ##

Creating an VPC named Main.

## Internet Gateway ## 

The Internet gateway is the medium where the cloud interacts with the internet

## 2 Public subnets and 2 Private subnet ##

1. Main VPC public subnet 1 in AZ 2
2. Main VPC public subnet 2 in AZ 2
3. Main VPC private subnet 1 in AZ 1
4. Main VPC private subnet 2 in AZ 2

## NAT Gateway ##

The NAT gateway provides outbound internet access to private subnet. It also transalates public traffic to private. It resides inside 
# the publi subnet. Since only one of the private subnet requires internet access, I have created only one NAT gateway

## Public routeTable ##
This route table will have a default rule o allow all outbound traffic routed to the internet gateway.

## SERVER INFRA ##

 The infrastructure contains 2 security groups, one for Private EC2 Instance and another for Public EC2 Instance.
 
 ## SECURITY GROUPS ##
 
 1. Public Security group

A security group acts as a virtual firewall for your EC2 instances to control incoming and outgoing traffic

 2. Private Security group

A security group acts as a virtual firewall for your EC2 instances to control incoming and outgoing traffic. This security group only contains inbound rules.

 3. Load Balancer Sec Group

A security group for the load balancer

## Public EC2 ##

A EC2 Instane created using Linux base image 

## Private EC2 ##

A EC2 Instane created using Ubuntu version 20 base image

## Target Group ##

A target group tells a load balancer where to direct traffic to

## Load Balancer ##

Elastic Load Balancing automatically distributes your incoming traffic across multiple targets, such as EC2 instances. Since I have two EC2, I decided to create a load balancer.

## Listner and Listner rules ##

A load balancer requires a listener. A listener is a process that checks for connection requests using the protocol and port that you specify in your code.
a listener rule determines how the load balancer routes request to the registered targets.
