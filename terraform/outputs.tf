output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.radius.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.radius.public_ip
}

output "private_key_file" {
  description = "Path to the generated PEM private key"
  value       = local_file.radius_private_key.filename
}
