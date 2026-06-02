variable "bucket_name" { type = string }
variable "lambda_name" { type = string }
variable "lambda_code_path" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
