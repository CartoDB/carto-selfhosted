resource "aws_elasticache_cluster" "example" {
  cluster_id           = "carto-redis-default"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.0"
  port                 = 6379
}
