terraform {
	backend "s3" {
		bucket = "xjg.terraformstate"
		key = "2-between-az-private-ip.tfstate"
		region = "eu-west-2"
		dynamodb_table = "terraform-state"
	}
}

locals {
    transfer_test = "2"
    tags = {
        Project = "NGINX-Test"
        env = "Test"
        transfer_test = local.transfer_test
    }
}

provider aws {
    profile = "personal"
    region = "eu-west-2"

    default_tags {
        tags = local.tags
    }
}

module nginx {
    source = "github.com/joaquimxg/tf-instance-module"

    tag_name = "t${local.transfer_test}-nginx"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "../nginx/playbook.yml"
    ansible_vars = {
        public_ip = module.server.private_ip
    }

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "test-${local.transfer_test}-nginx"
        ttl = 60
    }

}

module server {
    source = "github.com/joaquimxg/tf-instance-module"

    tag_name = "t${local.transfer_test}-server"
    region = "eu-west-2"
    az = "eu-west-2b"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-d1b2149d"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "../server/playbook.yml"
    ansible_vars = {
        HTTP_PORT = "80"
        FILE_NAME = "random.bin"
        TEST_NAME = "${local.transfer_test}"
    }

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "test-${local.transfer_test}-server"
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