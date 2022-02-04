
terraform {
	backend "s3" {
		bucket = "xjg.terraformstate"
		key = "serverTest.tfstate"
		region = "eu-west-2"
		dynamodb_table = "terraform-state"
	}
}

variable default_tags {
    default = {
        Project = "Server-Test"
        env = "Test"
    }
}

provider aws {
    profile = "personal"
    region = "eu-west-2"

    default_tags {
        tags = var.default_tags
    }
}

module server {
    source = "./terraform-module"

    tag_name = "Server-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    subdomain = "server-test"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "./playbook.yml"
    ansible_vars = {
        HTTP_PORT = "80"
        FILE_NAME = "random.bin"
        TEST_NAME = "test"
    }
}

output server {
    value = {
        ip = "${module.server.public_ip}"
        private_ip = "${module.server.private_ip}"
        dns = "${module.server.dns}"
    }
}