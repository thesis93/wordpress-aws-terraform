output "wordpress_url" {
  description = "Open this in a browser to reach WordPress through the load balancer."
  value       = "http://${aws_lb.wordpress.dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.wordpress.dns_name
}

output "db_endpoint" {
  description = "Private IP of the MySQL (MariaDB) database instance (reachable only from the EC2 fleet)."
  value       = aws_instance.db.private_ip
}

output "db_password" {
  description = "Generated database password. View with: terraform output -raw db_password"
  value       = random_password.db.result
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}
