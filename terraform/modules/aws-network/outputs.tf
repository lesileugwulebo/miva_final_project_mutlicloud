output "vpc_id" {
  value       = aws_vpc.hub.id
  description = "The ID of the AWS VPC"
}

output "web_subnet_id" {
  value       = aws_subnet.web.id
  description = "The ID of the Web subnet"
}

output "app_subnet_id" {
  value       = aws_subnet.app.id
  description = "The ID of the App subnet"
}

output "db_subnet_id" {
  value       = aws_subnet.db.id
  description = "The ID of the DB subnet"
}

output "mgmt_subnet_id" {
  value       = aws_subnet.mgmt.id
  description = "The ID of the Mgmt subnet"
}

output "vpc_cidr_block" {
  value       = aws_vpc.hub.cidr_block
  description = "The CIDR block of the AWS VPC"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "The ID of the public route table"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "The ID of the private route table"
}
