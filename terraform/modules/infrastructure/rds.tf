resource "aws_db_subnet_group" "dsg" {
  name       = var.project
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Project = var.project
  }
}

resource "aws_db_instance" "rds" {
  identifier             = var.project
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "11.5"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = var.db_user
  password               = var.db_pass
  db_subnet_group_name   = aws_db_subnet_group.dsg.id
  vpc_security_group_ids = [aws_security_group.rds.id]
  #   publicly_accessible    = true
  skip_final_snapshot = true
  tags = {
    Project = var.project
  }
}
