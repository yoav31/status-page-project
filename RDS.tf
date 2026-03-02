# RDS Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "yoav-db-subnet-group"
  subnet_ids = [aws_subnet.private_data_1.id, aws_subnet.private_data_2.id]

  tags = {
    Name = "YOAV_DB_SUBNET_GROUP"
  }
}

# RDS Instance
resource "aws_db_instance" "yoav_project_db" {
  identifier           = "yoav-project-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.10" # Standard stable version
  instance_class       = "db.t3.micro"
  db_name              = "statuspage"
  username             = "yoav_admin"
  password             = "#Aa123456#" # User should change this later or use a secret manager
  parameter_group_name = "default.postgres15"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.data_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false

  tags = {
    Name = "yoav-project-db"
  }
}
