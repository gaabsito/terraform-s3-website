variable "aws_region" {
  description = "Región AWS en la que existe el bucket de la práctica anterior."
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "Nombre globalmente único del bucket S3 creado previamente con Terraform."
  type        = string
}
