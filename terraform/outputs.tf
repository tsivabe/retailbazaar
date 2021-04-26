output "clb_dns_name" {
  value       = aws_elb.retail.dns_name
  description = "Domain name of LB"
}
