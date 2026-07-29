output "web_sg_id" {
  value       = aws_security_group.web.id
  description = "The ID of the Web security group"
}

output "app_sg_id" {
  value       = aws_security_group.app.id
  description = "The ID of the App security group"
}

output "db_sg_id" {
  value       = aws_security_group.db.id
  description = "The ID of the DB security group"
}

output "mgmt_sg_id" {
  value       = aws_security_group.mgmt.id
  description = "The ID of the Mgmt security group"
}

output "kms_key_arn" {
  value       = aws_kms_key.db_key.arn
  description = "The ARN of the database encryption KMS key"
}

output "federated_role_arn" {
  value       = aws_iam_role.federated_workload.arn
  description = "The ARN of the federated IAM role"
}
