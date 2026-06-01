# ============================================================================
# DynamoDB Module
# ============================================================================

resource "aws_dynamodb_table" "products" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "productId"
  range_key      = "category"

  attribute {
    name = "productId"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.tags, {
    Name    = var.table_name
    Project = "karatu-2025-capstone"
  })
}
