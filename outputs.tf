output "subnet_id" {
  description = "ID da subnete criada para CE Mapfre"
  value       = aws_subnet.ce_subnets.*.id[0]
}

output "security_group_id" {
  description = "ID do SG criado para CE Mapfre"
  value       = aws_security_group.ce_sg.id
}