output "public_ip" {
  value = aws_instance.mcserver.public_ip
}

output "host" {
  value = aws_route53_record.mcserver.name
}
