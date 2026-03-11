# 1. Security Group for ALB (Internet facing)
resource "aws_security_group" "alb_sg" {
  name        = "YOAV_ALB_SG"
  description = "Security Group for the Status Page Application Load Balancer"
  vpc_id      = module.vpc.vpc_id # תוקן לפי הקוד שלך!

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

# 2. Security Group for APP (Pods)
resource "aws_security_group" "app_sg" {
  name        = "YOAV_APP_SG"
  description = "Security Group for Status Page App Pods"
  vpc_id      = module.vpc.vpc_id # תוקן לפי הקוד שלך!

  # מקבל תעבורה *רק* מה-Load Balancer
  ingress {
    from_port       = 8000
    to_port         = 8000
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

# 3. Security Group for RDS and Redis (The Data Tier)
resource "aws_security_group" "data_sg" {
  name        = "yoav-data-sg"
  description = "Security group for internal databases"
  vpc_id      = module.vpc.vpc_id # תוקן לפי הקוד שלך!

  # חוק עבור הפוסטגרס - פתוח *רק* ל-App
  ingress {
    description     = "Allow PostgreSQL traffic from App SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # חוק עבור ה-Redis - פתוח *רק* ל-App
  ingress {
    description     = "Allow Redis traffic from App SG"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # יציאה חופשית החוצה
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