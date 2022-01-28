data aws_route53_zone joaquim {
  name         = var.domain
  private_zone = false
}

resource aws_route53_record server {
  zone_id = data.aws_route53_zone.joaquim.zone_id
  name = "${var.subdomain}.${data.aws_route53_zone.joaquim.name}"
  type = "A"
  ttl = 60
  records = [aws_instance.server.public_ip]
}