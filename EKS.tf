
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "yoav-terraform-eks"
  cluster_version = "1.31"
  cluster_endpoint_public_access = true

  vpc_id     = "vpc-096ce808921d8bc38"
  subnet_ids = ["subnet-009d28a45c357716f", "subnet-02320e1941e421022"]
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
