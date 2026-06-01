output "dev_user_access_key" {
  value     = aws_iam_access_key.dev.id
  sensitive = false
}

output "dev_user_secret_key" {
  value     = aws_iam_access_key.dev.secret
  sensitive = true
}

output "dev_user_password" {
  value     = aws_iam_user_login_profile.dev.password
  sensitive = true
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}
