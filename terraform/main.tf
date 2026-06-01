# ============================================================================
# Project Bedrock — InnovateMart EKS Infrastructure
# ============================================================================
# Production-grade microservices platform on AWS EKS
# Tag: Project = "karatu-2025-capstone"
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    bucket = "project-bedrock-state-alt-soe-025-3621"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "karatu-2025-capstone"
      ManagedBy = "terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ============================================================================
# VPC Module
# ============================================================================
module "vpc" {
  source = "./modules/vpc"
  
  name               = "project-bedrock-vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  tags = {
    Project = "karatu-2025-capstone"
  }
}

# ============================================================================
# IAM Module
# ============================================================================
module "iam" {
  source = "./modules/iam"
  
  region           = var.region
  s3_bucket_name   = module.s3_lambda.assets_bucket_name
  cluster_name     = module.eks.cluster_name
  cluster_arn      = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn
}

# ============================================================================
# EKS Module
# ============================================================================
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = "project-bedrock-cluster"
  cluster_version = "1.34"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  public_subnets  = module.vpc.public_subnet_ids
  
  node_groups = {
    general = {
      desired_size   = 2
      min_size       = 1
      max_size       = 4
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
  
  tags = {
    Project = "karatu-2025-capstone"
  }
}

# ============================================================================
# RDS Module (MySQL + PostgreSQL)
# ============================================================================
module "rds" {
  source = "./modules/rds"
  
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.node_security_group_id
  
  mysql_db_name     = "retail_mysql"
  postgres_db_name  = "retail_postgres"
  
  tags = {
    Project = "karatu-2025-capstone"
  }
}

# ============================================================================
# DynamoDB Module
# ============================================================================
module "dynamodb" {
  source = "./modules/dynamodb"
  
  table_name = "retail-store-products"
  tags = {
    Project = "karatu-2025-capstone"
  }
}

# ============================================================================
# S3 + Lambda Module
# ============================================================================
module "s3_lambda" {
  source = "./modules/s3_lambda"
  
  bucket_name      = var.assets_bucket_name
  lambda_name      = "bedrock-asset-processor"
  lambda_code_path = "${path.module}/../lambda"
  
  tags = {
    Project = "karatu-2025-capstone"
  }
}
