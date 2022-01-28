terraform {
	backend "s3" {
		bucket = "xjg.terraformstate"
		key = "nginx-test.tfstate"
		region = "eu-west-2"
		dynamodb_table = "terraform-state"
	}
}

variable default_tags {
    default = {
        Project = "Nginx-Test"
        env = "Test"
    }
}

provider aws {
    profile = "personal"
    region = "eu-west-2"

    default_tags {
        tags = var.default_tags
    }

    alias = "london"
}

provider aws {
    profile = "personal"
    region = "eu-west-1"

    default_tags {
        tags = var.default_tags
    }

    alias = "ireland"
}

module nginx {
    source = "./nginx/terraform-module"

    tag_name = "nginx-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    subdomain = "nginx-test"
    security_group_id = "sg-04ae5e949212df7db"
    reverse_proxy_target = module.server.public_ip
    playbook_path = "./nginx/playbook.yml"

    providers = {
        aws = aws.london
    }
}

module server {
    source = "./server/terraform-module"

    tag_name = "server-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    subdomain = "server-test"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "./server/playbook.yml"

    providers = {
        aws = aws.london
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