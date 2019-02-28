resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}-${var.env}-rds-sg"
  description = "RDS subnet group"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
}

resource "aws_db_instance" "instance" {
  identifier                = "${var.name}-${var.env}"
  allocated_storage         = "${var.database_allocated_storage}"
  engine                    = "postgres"
  engine_version            = "9.6.9"
  instance_class            = "${var.database_instance_class}"
  multi_az                  = "${var.database_multi_az}"
  name                      = "${var.database_name}"
  username                  = "${var.database_username}"
  password                  = "${var.database_password}"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.rds.id}"
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.name}-${var.env}-final"
}
