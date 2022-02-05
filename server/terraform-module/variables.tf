variable tag_name {}
variable region {}
variable az {}
variable vpc_id {}
variable subnet_id {}
variable subdomain {}
variable playbook_path {}

variable ansible_vars {
  type = map
}

variable security_group_id {
  default = null
}

variable instance_type {
  default = "t2.micro"
}

variable key_name {
  default = "aws-personal"
}

variable priv_key_path {
  default = "~/.ssh/aws-personal.pem"
}

variable domain {
  default = "joaquimgomez.com."
}