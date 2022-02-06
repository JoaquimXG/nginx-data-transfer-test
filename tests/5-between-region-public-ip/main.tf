terraform {
	backend "s3" {
		bucket = "xjg.terraformstate"
		key = "5-between-region-public-ip.tfstate"
		region = "eu-west-2"
		dynamodb_table = "terraform-state"
	}
}

variable workspace_iam_roles {
    default = {
        aws2 = "arn:aws:iam::232870009830:role/OrganizationAccountAccessRole"
        nginx = "arn:aws:iam::261567139318:role/OrganizationAccountAccessRole"
        default = null
    }
}

locals {
    transfer_test = "5"
    tags = {
        Project = "NGINX-Test"
        env = "Test"
        transfer_test = local.transfer_test
    }
}

provider aws {
    region = "eu-west-2"

    default_tags {
        tags = local.tags
    }

    alias = "london"

    assume_role {
        role_arn = "${var.workspace_iam_roles[terraform.workspace]}"
    } 
}

provider aws {
    region = "eu-west-1"

    default_tags {
        tags = local.tags
    }

    alias = "ireland"

    assume_role {
        role_arn = "${var.workspace_iam_roles[terraform.workspace]}"
    } 
}

module london_network {
    source = "github.com/JoaquimXG/terraform-modules/default-vpc-and-subnet"

    az = "eu-west-2a"

    providers = {
        aws = aws.london
    } 
}

module ireland_network {
    source = "github.com/JoaquimXG/terraform-modules/default-vpc-and-subnet"

    az = "eu-west-1a"

    providers = {
        aws = aws.ireland
    } 
}

module nginx {
    source = "github.com/JoaquimXG/terraform-modules/ansible-instance"

    tag_name = "t${local.transfer_test}-nginx"
    region = "eu-west-2"
    az = "eu-west-2a"
    vpc_id = module.london_network.vpc_id
    subnet_id = module.london_network.subnet_id
    # security_group_id = "sg-04ae5e949212df7db"
    playbook_path = "../../nginx/playbook.yml"
    ansible_vars = {
        public_ip = module.server.public_ip
    }

    dns = {
        domain = "joaquimgomez.com"
        subdomain = "test-${local.transfer_test}-nginx"
        ttl = 60
    }

    providers = {
        aws = aws.london
    }
}

module server {
    source = "github.com/JoaquimXG/terraform-modules/ansible-instance"

    tag_name = "t${local.transfer_test}-server"
    region = "eu-west-1"
    az = "eu-west-1a"
    vpc_id = module.ireland_network.vpc_id
    subnet_id = module.ireland_network.subnet_id
    # security_group_id = "sg-0918f5ee9f71d0928"
    playbook_path = "../../server/playbook.yml"
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
    providers = {
        aws = aws.ireland
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