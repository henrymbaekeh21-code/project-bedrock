variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "assets_bucket_name" {
  description = "S3 bucket name for assets (must include student ID)"
  type        = string
}

variable "student_id" {
  description = "Student ID for unique resource naming"
  type        = string
}
