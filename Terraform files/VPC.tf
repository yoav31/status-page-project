module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "YOAV_PROJECT_VPC"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b"]

  # השכבה הציבורית (Public)
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_names = ["YOAV_PUBLIC_SUBNET1", "YOAV_PUBLIC_SUBNET2"]

  # שכבת האפליקציה (Private App)
  private_subnets      = ["10.0.11.0/24", "10.0.12.0/24"]
  private_subnet_names = ["YOAV_PRIVATE_SUBNET_APP1", "YOAV_PRIVATE_SUBNET_APP2"]

  # שכבת הנתונים (Private Data)
  database_subnets      = ["10.0.21.0/24", "10.0.22.0/24"]
  database_subnet_names = ["YOAV_PRIVATE_SUBNET_DATA1", "YOAV_PRIVATE_SUBNET_DATA2"]

  # הגדרת ה-NAT Gateway (בדיוק כמו בתמונה - 1 ENI)
  enable_nat_gateway = true
  single_nat_gateway = true

  # הגדרת שמות לטבלאות הניתוב שיופיעו יפה ב-AWS
  public_route_table_tags   = { Name = "YOAV_PUBLIC_RT" }
  private_route_table_tags  = { Name = "YOAV_PRIVATE_APP_RT" }
  database_route_table_tags = { Name = "YOAV_PRIVATE_DATA_RT" }

  # תגיות קריטיות לקוברנטיס (חובה ל-Load Balancers)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# הגדרת ה-S3 Gateway Endpoint שמופיע אצלך בשרטוט
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name = "yoav-project-s3-gw"
  }
}