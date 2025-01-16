output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP address of the bastion host"
}

output "bastion_host" {
  value       = aws_instance.bastion.id
  description = "ID of the bastion host"
}


output "private_key" {
  value     = tls_private_key.bastion_ssh_key.private_key_pem
  sensitive = true
}

output "ec2_instances_id" {
  value = [aws_instance.bastion.id, aws_instance.airflow_webserver.id, aws_instance.airflow_worker.id]
  description = "ID of all EC2 instances"
}

output "bastion_ssh_private_key_command" {
  value = "aws ssm get-parameter --name \"$/{var.project_name}/ec2/bastion-key\" --with-decryption --query \"Parameter.Value\" --output text > ${var.project_name}-bastion-key.pem"
  description = "value of the command to retrieve the private key from SSM"
}

output "private_ssh_private_key_command" {
  value = "aws ssm get-parameter --name '/${var.project_name}/ec2/private-key' --with-decryption --query 'Parameter.Value' --output text > ${var.project_name}-private-key.pem"
  description = "value of the command to retrieve the private key from SSM"
}

output "private_key1" {
  value     = tls_private_key.bastion_ssh_key.private_key_pem
  sensitive = true
}

output "sg_private_instances"{ 
  value = aws_security_group.private_instances.id
  description = "ID of the security group for private instances"
}

output "sg_bastion" {
  value = aws_security_group.bastion.id
  description = "ID of the security group for the bastion host"
}