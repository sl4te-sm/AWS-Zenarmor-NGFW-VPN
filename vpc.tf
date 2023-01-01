/*
vpc.tf
Configuration file for creating the VPC and subnets for the firewall

Two public subnets are created for the firewall/VPN servers
Three private subnets are created for the opensearch cluster
*/

// Creates the VPC for the full application
resource "aws_vpc" "aws-ngfw" {
    // Change this to whatever
    // Class B (172.16.0.0 - 172.31.255.255) is recommended
    //  * 192.168.0.0/16 is used for most home networks
    //  * 10.0.0.0/8 is likely to conflict with corporate VPN setups
    cidr_block = "172.20.0.0/16"
    enable_dns_support = "true" // Generate internal domain name
    enable_dns_hostnames = "true" // Generate internal host names
    enable_classiclink = "false"
    instance_tenancy = "default"
    
    tags {
        Name = "aws_ngfw"
    }
}

// Creates the first public subnet for the VPN servers
resource "aws_subnet" "vpn-subnet-A" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"
    cidr_block = "172.20.10.0/24"
    map_public_ip_on_launch = "true" // Makes this subnet public
    availability_zone = "us-east-2a" // Change this to match your region

    tags {
        Name = "vpn-subnet-A"
    }
}

// Creates the second public subnet for the VPN servers
resource "aws_subnet" "vpn-subnet-B" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"
    cidr_block = "172.20.11.0/24"
    map_public_ip_on_launch = "true" // Makes this subnet public
    availability_zone = "us-east-2b" // Change this to match your region

    tags {
        Name = "vpn-subnet-B"
    }
}

// Creates the first private subnet for the VPN servers
resource "aws_subnet" "search-subnet-A" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"
    cidr_block = "172.20.20.0/24"
    map_public_ip_on_launch = "false" // Makes this subnet private
    availability_zone = "us-east-2a" // Change this to match your region

    tags {
        Name = "search-subnet-A"
    }
}

// Creates the second private subnet for the VPN servers
resource "aws_subnet" "search-subnet-B" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"
    cidr_block = "172.20.21.0/24"
    map_public_ip_on_launch = "false" // Makes this subnet private
    availability_zone = "us-east-2b" // Change this to match your region

    tags {
        Name = "search-subnet-B"
    }
}