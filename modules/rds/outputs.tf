output "rds-endpoint" {
  value = aws_db_instance.customer-rds.address
}

output "rds-username" {
  value = aws_db_instance.customer-rds.username
}

output "rds-password" {
  value = aws_db_instance.customer-rds.password
}

output "rds-db-name" {
  value = aws_db_instance.customer-rds.db_name
}



