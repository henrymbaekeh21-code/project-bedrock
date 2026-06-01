output "cluster_endpoint" {
  description = "EKS cluster endpoint for grading"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name for grading"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region for grading"
  value       = var.region
}

output "vpc_id" {
  description = "VPC ID for grading"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name for grading"
  value       = module.s3_lambda.assets_bucket_name
}

output "bedrock_dev_access_key" {
  description = "Access key for bedrock-dev-view user"
  value       = module.iam.dev_user_access_key
  sensitive   = true
}

output "bedrock_dev_secret_key" {
  description = "Secret key for bedrock-dev-view user"
  value       = module.iam.dev_user_secret_key
  sensitive   = true
}

output "mysql_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.mysql_endpoint
}

output "postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.postgres_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}
