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

    alias = "west"
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
    reverse_proxy_target = "joaquimgomez.com"
    playbook_path = "./nginx/playbook.yml"

    providers = {
        aws = aws.west
    }
}

output nginx_ip {
    value = "${module.nginx.ip}"
}

output nginx_dns {
    value = "${module.nginx.dns}"
}