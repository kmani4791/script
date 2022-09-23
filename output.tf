output "es_domain_endpoint" {
    value = aws_elasticsearch_domain.es.endpoint
}

output "es_kibana_endpoint" {
    value = aws_elasticsearch_domain.es.kibana_endpoint
}

output "security_group_arn" {
    value = aws_security_group.es.arn
}
