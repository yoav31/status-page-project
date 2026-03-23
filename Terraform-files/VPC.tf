module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "YOAV_PROJECT_VPC"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b"]

  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_names = ["YOAV_PUBLIC_SUBNET1", "YOAV_PUBLIC_SUBNET2"]

  private_subnets      = ["10.0.11.0/24", "10.0.12.0/24"]
  private_subnet_names = ["YOAV_PRIVATE_SUBNET_APP1", "YOAV_PRIVATE_SUBNET_APP2"]

  database_subnets      = ["10.0.21.0/24", "10.0.22.0/24"]
  database_subnet_names = ["YOAV_PRIVATE_SUBNET_DATA1", "YOAV_PRIVATE_SUBNET_DATA2"]
  create_database_subnet_route_table = true
  create_database_nat_gateway_route = false
  igw_tags = {
      Name = "yoav_project_igw"
    }
  nat_gateway_tags = {
    Name = "yoav_project_nat"
  }  
  enable_nat_gateway = true
  single_nat_gateway = true

  public_route_table_tags   = { Name = "YOAV_PUBLIC_RT" }
  private_route_table_tags  = { Name = "YOAV_PRIVATE_APP_RT" }
  database_route_table_tags = { Name = "YOAV_PRIVATE_DATA_RT" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name = "yoav-project-s3-gw"
  }
}