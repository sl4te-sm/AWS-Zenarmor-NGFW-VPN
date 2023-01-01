// Create internet gateway for the public subnets
resource "aws_internet_gateway" "ngfw-igw" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"
    tags {
        Name = "ngfw-igw"
    }
}

// Creates the route table for the public subnets to the internet gateway
resource "aws_route_table" "vpn-rt" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"

    route {
        // Allow the subnets to reach the open internet
        cidr_block = "o.o.o.o/o"
        // Point the hosts to the IGW
        gateway_id = "${aws_internet_gateway.ngfw-igw.id}"

    }

    tags {
        Name = "vpn-rt"
    }
}

// Associate the public subnets with the route table
resource "aws_route_table_association" "vpn-subnet-A-rta" {
    subnet_id = "${aws_subnet.vpn-subnet-A.id}"
    route_table_id = "${aws_route_table.vpn-rt.id}"
}
resource "aws_route_table_association" "vpn_subnet_B-rta" {
    subnet_id = "${aws_subnet.vpn-subnet-B.id}"
    route_table_id = "${aws_route_table.vpn-rt.id}"
}

// Create the security group for the VPN servers
resource "aws_security_group" "vpn-sg" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"

    // Allow all egress traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Allow SSH access only from your personal address(es)
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.HOUSE_IP}"]
    }

    // Allow HTTPS access only from your personal address(es)
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.HOUSE_IP}"]
    }

    // Allow wireguard access from everywhere
    ingress {
        from_port = 51820
        to_port = 51820
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "vpn-sg"
    }
}

// Create the security group for the opensearch cluster
resource "aws_security_group" "search-sg" {
    vpc_id = "${aws_vpc.aws-ngfw.id}"

    // Allow all egress traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    // Allow HTTPS access only from the vpn security group
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = ["${vpn-sg}"]
    }

     // Allow HTTP access only from the vpn security group
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["${vpn-sg}"]
    }

    tags {
        Name = "search-sg"
    }
}
