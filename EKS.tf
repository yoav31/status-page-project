
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "yoav-terraform-eks"
  cluster_version = "1.34"
  cluster_endpoint_public_access = true

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private_app_1.id, aws_subnet.private_app_2.id]
  
  eks_managed_node_groups = {
    yoav_nodes = {
      instance_types = ["t3.medium"]
      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
  enable_cluster_creator_admin_permissions = true
}
