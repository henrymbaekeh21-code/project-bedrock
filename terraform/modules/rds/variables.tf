variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "eks_security_group_id" { type = string }
variable "mysql_db_name" { type = string }
variable "postgres_db_name" { type = string }
variable "tags" { type = map(string) default = {} }
