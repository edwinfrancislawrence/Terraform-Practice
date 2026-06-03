output "PublicIP" {
    value = aws_instance.name.public_ip
  
}

output "PrivateIP" {
    value = aws_instance.name.private_ip
  
}

output "Subnet_id" {
    value = aws_instance.name.subnet_id
  
}