terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.70.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Project   = "practica-devops-00"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid       = "PublicReadWebsiteFiles"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.site.id
  policy     = data.aws_iam_policy_document.public_read.json
  depends_on = [aws_s3_bucket_public_access_block.site]
}

locals {
  website_files = {
    "index.html" = "text/html; charset=utf-8"
    "style.css"  = "text/css; charset=utf-8"
    "js/app.js"  = "application/javascript; charset=utf-8"
  }
}

# Los contenidos forman parte de la infraestructura: al cambiar un archivo,
# su etag hace que Terraform lo vuelva a publicar en el bucket.
resource "aws_s3_bucket_object" "website_files" {
  for_each = local.website_files

  bucket       = aws_s3_bucket.site.id
  key          = each.key
  source       = "${path.module}/${each.key}"
  etag         = filemd5("${path.module}/${each.key}")
  content_type = each.value

  depends_on = [aws_s3_bucket_policy.public_read]
}
