output ip {
  value = aws_instance.nginx.public_ip
}

output dns {
  value = aws_route53_record.nginx.name
}