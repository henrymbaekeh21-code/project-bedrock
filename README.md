# Project Bedrock — InnovateMart EKS Infrastructure

> Production-grade microservices platform on AWS EKS

## Architecture

```
                    [Internet]
                        |
                  [CloudFront / ALB]
                        |
              +---------+---------+
              |                   |
        [EKS Cluster]      [S3 Bucket]
        retail-app         bedrock-assets
              |
    +---------+---------+
    |         |         |
  [UI Pods] [Orders] [Catalog]
    |
    +--------+--------+
             |
    +--------+--------+
    |         |         |
 [RDS     [RDS      [DynamoDB
  MySQL]   PostgreSQL] Products]
    |
  [ElastiCache
   Redis]
```

## Repository Structure

```
project-bedrock/
├── terraform/            # Infrastructure as Code
│   ├── modules/
│   │   ├── vpc/          # VPC, subnets, NAT, IGW
│   │   ├── eks/          # EKS cluster + node groups
│   │   ├── rds/          # MySQL + PostgreSQL
│   │   ├── dynamodb/     # DynamoDB table
│   │   ├── s3_lambda/    # S3 bucket + Lambda
│   │   └── iam/          # IAM roles + dev user
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── kubernetes/           # K8s manifests
│   └── base/
│       ├── namespace.yaml
│       ├── ui-deployment.yaml
│       ├── ingress.yaml
│       └── serviceaccount.yaml
├── lambda/               # Lambda function code
│   └── index.py
├── .github/
│   └── workflows/
│       └── terraform-pipeline.yml
└── README.md
```

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- kubectl
- GitHub repository with secrets configured

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/YOUR_USERNAME/project-bedrock.git
cd project-bedrock
```

### 2. Set Up GitHub Secrets

Go to Settings → Secrets → Actions and add:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `ASSETS_BUCKET_NAME` | `bedrock-assets-YOUR_STUDENT_ID` |
| `STUDENT_ID` | Your student ID |

### 3. Create Terraform State Bucket

```bash
aws s3 mb s3://project-bedrock-terraform-state --region us-east-1
```

### 4. Deploy Locally (or push to trigger CI/CD)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply -auto-approve
```

### 5. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster
```

### 6. Install AWS Load Balancer Controller

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=project-bedrock-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 7. Deploy the Application

```bash
kubectl apply -k kubernetes/base/
```

### 8. Verify

```bash
kubectl get pods -n retail-app
kubectl get ingress -n retail-app
# Get the ALB URL
kubectl get ingress ui -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Grading Credentials

After deployment, get the developer credentials:

```bash
terraform output bedrock_dev_access_key
terraform output bedrock_dev_secret_key
```

## Tagging

All resources are tagged with:
```
Project: karatu-2025-capstone
```

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```

**Warning**: This will delete all AWS resources created by Terraform.
