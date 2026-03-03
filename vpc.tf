# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "YOAV_PROJECT_VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "YOAV_IGW"
  }
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "YOAV_PUBLIC_SUBNET1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "YOAV_PUBLIC_SUBNET2"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "YOAV_PRIVATE_SUBNET_APP1"
  }
}

resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "YOAV_PRIVATE_SUBNET_APP2"
  }
}

# Private Data Subnets
resource "aws_subnet" "private_data_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "YOAV_PRIVATE_SUBNET_DATA1"
  }
}

resource "aws_subnet" "private_data_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "YOAV_PRIVATE_SUBNET_DATA2"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "YOAV_NAT_EIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "YOAV_NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Table: Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "YOAV_PUBLIC_RT"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Route Table: Private App (With NAT Gateway)
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "YOAV_PRIVATE_APP_RT"
  }
}

resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private_app.id
}

# Route Table: Private Data
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "YOAV_PRIVATE_DATA_RT"
  }
}

resource "aws_route_table_association" "private_data_1" {
  subnet_id      = aws_subnet.private_data_1.id
  route_table_id = aws_route_table.private_data.id
}

resource "aws_route_table_association" "private_data_2" {
  subnet_id      = aws_subnet.private_data_2.id
  route_table_id = aws_route_table.private_data.id
}

# --- Security Groups (Fixed Circular Dependencies) ---

# 1. Default VPC Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. YOAV_ALB_SG (Static Load Balancer SG)
resource "aws_security_group" "alb_sg" {
  name        = "YOAV_ALB_SG"
  description = "Security Group for the Status Page Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "YOAV_ALB_SG"
  }
}

resource "aws_security_group_rule" "alb_from_app" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.app_sg.id
  description              = "Allow communication on port 5000 from App SG"
}

# 3. k8s-elb-... (Kubernetes Dynamic Load Balancer SG)
resource "aws_security_group" "k8s_elb_sg" {
  name        = "k8s-elb-a31c74066e060439fa2db7790532e382"
  description = "Security group for Kubernetes ELB a31c74066e060439fa2db7790532e382"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3
    to_port     = 4
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-elb-a31c74066e060439fa2db7790532e382"
  }
}

# 4. YOAV_APP_SG (Application Pods SG)
resource "aws_security_group" "app_sg" {
  name        = "YOAV_APP_SG"
  description = "Security Group for Status Page App Pods"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "YOAV_APP_SG"
  }
}

resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.data_sg.id
  source_security_group_id = aws_security_group.app_sg.id
  description              = "Allow app pods to access PostgreSQL"
}

resource "aws_security_group_rule" "app_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.data_sg.id
  source_security_group_id = aws_security_group.app_sg.id
  description              = "Allow app pods to access Redis"
}

# 5. YOAV_DATA_SG (Databases SG)
resource "aws_security_group" "data_sg" {
  name        = "YOAV_DATA_SG"
  description = "Security Group for PostgreSQL and Redis Databases"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "YOAV_DATA_SG"
  }
}

resource "aws_security_group_rule" "db_from_nodes" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.data_sg.id
  source_security_group_id = module.eks.node_security_group_id
}

# 6. EKS Node Shared SG
resource "aws_security_group" "eks_node_sg" {
  name        = "yoav-terraform-eks-node-shared"
  description = "EKS node shared security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yoav-terraform-eks-node-shared"
  }
}

resource "aws_security_group_rule" "nodes_from_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

# 7. EKS Control Plane / Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg-yoav-terraform-eks"
  description = "EKS created security group applied to Control Plane"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg-yoav-terraform-eks"
  }
}

resource "aws_security_group_rule" "cluster_from_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
}

# 8. EKS API Security Group
resource "aws_security_group" "eks_api_sg" {
  name        = "yoav-terraform-eks-cluster-api"
  description = "EKS cluster security group for API access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
  }

  tags = {
    Name = "yoav-terraform-eks-cluster-api"
  }
}
