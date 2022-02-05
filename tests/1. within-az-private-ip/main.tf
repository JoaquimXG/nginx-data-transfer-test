terraform {
	backend "s3" {
		bucket = "xjg.terraformstate"
		key = "1-within-az-private-ip.tfstate"
		region = "eu-west-2"
		dynamodb_table = "terraform-state"
	}
}

variable transfer_test {
    default = "1"
}

variable default_tags {
    default = {
        Project = "NGINX-Test"
        env = "Test"
        transfer_test = var.transfer_test
    }
}

provider aws {
    profile = "personal"
    region = "eu-west-2"

    default_tags {
        tags = var.default_tags
    }
}

module nginx {
    source = "github.com/joaquimxg/tf-instance-module"

    tag_name = "nginx-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "../../nginx/playbook.yml"
    ansible_vars = {
        public_ip = module.server.private_ip
    }

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "test-${var.transfer_test}-nginx"
        ttl = 60
    }
}

module server {
    source = "github.com/joaquimxg/tf-instance-module"

    tag_name = "server-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "../../server/playbook.yml"
    ansible_vars = {
        HTTP_PORT = "80"
        FILE_NAME = "random.bin"
        TEST_NAME = "${var.transfer_test}"
    }

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "test-${var.transfer_test}-server"
        ttl = 60
    }
}

output server {
    value = {
        ip = "${module.server.public_ip}"
        dns = "${module.server.dns}"
    }
}

output nginx {
    value = {
        ip = "${module.nginx.public_ip}"
        dns = "${module.nginx.dns}"
    }
}