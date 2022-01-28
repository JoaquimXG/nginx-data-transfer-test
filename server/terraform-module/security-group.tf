resource aws_security_group sg {
    name = "ssh_http_${var.tag_name}"
    description = "Allow inbound HTTP and SSH"
    vpc_id = var.vpc_id

    ingress {
        description = "HTTP"
        from_port = 0
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 0
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "sg-ssh_http_${var.tag_name}"
    }
}