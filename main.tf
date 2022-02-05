# terraform {
# 	backend "s3" {
# 		bucket = "xjg.terraformstate"
# 		key = "nginx-test.tfstate"
# 		region = "eu-west-2"
# 		dynamodb_table = "terraform-state"
# 	}
# }

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
    source = "github.com/joaquimxg/tf-instance-module"

    tag_name = "nginx-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "./nginx/playbook.yml"
    ansible_vars = {
        public_ip = module.server.public_ip
    }

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "nginx-test"
        ttl = 60
    }

    providers = {
        aws = aws.london
    }
}

module server {
    source = "github.com/joaquimxg/tf-instance-module"

    tag_name = "server-test"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = "vpc-18d09270"
    subnet_id = "subnet-f012828a"

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "server-test"
        ttl = 60
    }
    security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "./server/playbook.yml"

    ansible_vars = {
        HTTP_PORT = "80"
        FILE_NAME = "random.bin"
        TEST_NAME = "test"
    }

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