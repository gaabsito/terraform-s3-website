output "website_endpoint" {
  description = "Endpoint de hosting estático de S3 (HTTP)."
  value       = aws_s3_bucket.site.website_endpoint
}

output "website_url" {
  description = "URL que debes abrir en el navegador tras aplicar Terraform."
  value       = "http://${aws_s3_bucket.site.website_endpoint}"
}
