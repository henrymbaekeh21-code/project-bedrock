output "assets_bucket_name" { value = aws_s3_bucket.assets.id }
output "assets_bucket_arn" { value = aws_s3_bucket.assets.arn }
output "lambda_function_name" { value = aws_lambda_function.processor.function_name }
output "lambda_function_arn" { value = aws_lambda_function.processor.arn }
