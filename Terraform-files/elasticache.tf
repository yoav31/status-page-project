resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "yoav-redis-subnet-group"
  subnet_ids = module.vpc.database_subnets
}
resource "aws_elasticache_cluster" "yoav_redis" {
  cluster_id           = "yoav-project-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro" 
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.data_sg.id]
  tags = {
    Name = "yoav-project-redis"
  }
}