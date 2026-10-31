output "alb_dns_name" {
  description = "Public DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "health_check_url" {
  description = "Open this in a browser once the targets are healthy"
  value       = "http://${aws_lb.alb.dns_name}/health"
}

output "ecr_repository_url" {
  description = "Push your Docker image here"
  value       = aws_ecr_repository.todoapp.repository_url
}

output "db_private_ips" {
  description = "Replica set member addresses"
  value = {
    db_a = aws_instance.db-a-server.private_ip
    db_b = aws_instance.db-b-server.private_ip
    db_c = aws_instance.db-c-server.private_ip
  }
}