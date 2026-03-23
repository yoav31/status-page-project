module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name    = "yoav-project-cluster"
  cluster_version = "1.31" 
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  
  eks_managed_node_groups = {
    yoav_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
      
      vpc_security_group_ids = [aws_security_group.app_sg.id]
      
      tags = {
        Name = "yoav-project-node"
      }
    }
  }
  enable_cluster_creator_admin_permissions = true
}