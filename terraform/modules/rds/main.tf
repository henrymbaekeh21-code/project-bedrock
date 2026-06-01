# ============================================================================
# RDS Module — MySQL + PostgreSQL
# ============================================================================

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "bedrock-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name    = "bedrock-db-subnet-group"
    Project = "karatu-2025-capstone"
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "bedrock-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name    = "bedrock-rds-sg"
    Project = "karatu-2025-capstone"
  })
}

# Secrets Manager for MySQL
resource "aws_secretsmanager_secret" "mysql" {
  name                    = "bedrock/mysql-credentials"
  description             = "MySQL credentials for retail app"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Project = "karatu-2025-capstone" })
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = "retailmysql"
    password = random_password.mysql.result
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = var.mysql_db_name
  })
}

resource "random_password" "mysql" {
  length  = 16
  special = false
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier             = "bedrock-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = var.mysql_db_name
  username               = "retailmysql"
  password               = random_password.mysql.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true

  tags = merge(var.tags, {
    Name    = "bedrock-mysql"
    Project = "karatu-2025-capstone"
  })
}

# Secrets Manager for PostgreSQL
resource "aws_secretsmanager_secret" "postgres" {
  name                    = "bedrock/postgres-credentials"
  description             = "PostgreSQL credentials for retail app"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Project = "karatu-2025-capstone" })
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({
    username = "retailpostgres"
    password = random_password.postgres.result
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = var.postgres_db_name
  })
}

resource "random_password" "postgres" {
  length  = 16
  special = false
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier             = "bedrock-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = var.postgres_db_name
  username               = "retailpostgres"
  password               = random_password.postgres.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true

  tags = merge(var.tags, {
    Name    = "bedrock-postgres"
    Project = "karatu-2025-capstone"
  })
}
