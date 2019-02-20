/* subnet used by rds */
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.name}-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = ["${var.subnet_ids}"]
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.name}-db-access-sg"
  description = "Allow access to RDS"
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "${var.name} security group"
  vpc_id      = "${var.vpc_id}"

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  //allow traffic for TCP 5432
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.db_access_sg.id}"]
  }

  // outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.name}-database"
  allocated_storage      = "${var.allocated_storage}"
  engine                 = "postgres"
  engine_version         = "9.6.9"
  instance_class         = "${var.instance_class}"
  multi_az               = "${var.multi_az}"
  name                   = "${var.database_name}"
  username               = "${var.database_username}"
  password               = "${var.database_password}"
  skip_final_snapshot    = true
  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
}
