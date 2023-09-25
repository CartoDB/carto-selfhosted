#####################################################################################
# Terraform Examples:
# These are pieces of code added as configuration examples for guidance,
# therefore they may require additional resources and variable or local declarations.
#####################################################################################

locals {
  # Instance name
  redis_instance_name = "${var.redis_name}-${random_integer.random_redis.id}"
}

# Name suffix
resource "random_integer" "random_redis" {
  min = 1000
  max = 9999
}

# Redis instance
resource "aws_elasticache_cluster" "example" {
  cluster_id           = local.redis_instance_name
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.0"
  port                 = 6379
}
