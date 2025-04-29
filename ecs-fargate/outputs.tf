# outputs.tf

output "application_url" {
  value ="http://${aws_alb.main.dns_name}:8080/rolldice"
}