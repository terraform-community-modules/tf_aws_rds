# Read replicas

resource "aws_db_instance" "replica_rds_instance" {
  count               = "${length(var.read_replicas)}"
  replicate_source_db = "${aws_db_instance.main_rds_instance.id}"
  identifier          = "${lookup(var.read_replicas[count.index], "identifier")}"
  allocated_storage   = "${lookup(var.read_replicas[count.index], "rds_allocated_storage", var.rds_allocated_storage)}"
  engine              = "${lookup(var.read_replicas[count.index], "rds_engine_type", var.rds_engine_type)}"
  engine_version      = "${lookup(var.read_replicas[count.index], "rds_engine_version", var.rds_engine_version)}"
  instance_class      = "${lookup(var.read_replicas[count.index], "rds_instance_class", var.rds_instance_class)}"
  name                = "${lookup(var.read_replicas[count.index], "database_name", var.database_name)}"
  username            = "${lookup(var.read_replicas[count.index], "database_user", var.database_user)}"
  password            = "${lookup(var.read_replicas[count.index], "database_password", var.database_password)}"
  port                = "${lookup(var.read_replicas[count.index], "database_port", var.database_port)}"

  # Read replicas are created in the same security group as the master by default
  # If this is not the behavior your want, you must pass one or more alternate security group IDs in a comma-delimited string, and those security group IDs must already exist
  vpc_security_group_ids = ["${split(",", lookup(var.read_replicas[count.index], "vpc_security_group_ids", aws_security_group.main_db_access.id))}"]

  # Replicas in the same region as the master do not require a subnet group parameter
  db_subnet_group_name = ""
  parameter_group_name = "${aws_db_parameter_group.replica_rds_instance.*.id[count.index]}"

  # We want the multi-az setting to be toggleable, but off by default
  # Read replicas are not multi-az by default, even if the master is
  multi_az            = "${lookup(var.read_replicas[count.index], "rds_is_multi_az", "false")}"
  storage_type        = "${lookup(var.read_replicas[count.index], "rds_storage_type", var.rds_storage_type)}"
  iops                = "${lookup(var.read_replicas[count.index], "rds_iops", var.rds_iops)}"
  publicly_accessible = "${lookup(var.read_replicas[count.index], "publicly_accessible", var.publicly_accessible)}"

  # Upgrades
  allow_major_version_upgrade = "${lookup(var.read_replicas[count.index], "allow_major_version_upgrade", var.allow_major_version_upgrade)}"
  auto_minor_version_upgrade  = "${lookup(var.read_replicas[count.index], "auto_minor_version_upgrade", var.auto_minor_version_upgrade)}"
  apply_immediately           = "${lookup(var.read_replicas[count.index], "apply_immediately", var.apply_immediately)}"
  maintenance_window          = "${lookup(var.read_replicas[count.index], "maintenance_window", var.maintenance_window)}"

  # Snapshots and backups
  # By default, read replicas don't get backed up
  skip_final_snapshot     = "${lookup(var.read_replicas[count.index], "skip_final_snapshot", "true")}"
  copy_tags_to_snapshot   = "${lookup(var.read_replicas[count.index], "copy_tags_to_snapshot", var.copy_tags_to_snapshot)}"
  backup_retention_period = "${lookup(var.read_replicas[count.index], "backup_retention_period", 0)}"
  backup_window           = "${lookup(var.read_replicas[count.index], "backup_window", var.backup_window)}"

  tags = "${merge(var.tags, map("Name", format("%s", lookup(var.read_replicas[count.index], "identifier"))))}"

  depends_on = [
    "aws_db_parameter_group.replica_rds_instance",
  ]
}

resource "aws_db_parameter_group" "replica_rds_instance" {
  count  = "${length(var.read_replicas)}"
  name   = "${lookup(var.read_replicas[count.index], "identifier")}-${replace(lookup(var.read_replicas[count.index], "db_parameter_group", lookup(var.read_replicas[count.index], "db_parameter_group", var.db_parameter_group)), ".", "")}-custom-params"
  family = "${lookup(var.read_replicas[count.index], "db_parameter_group", lookup(var.read_replicas[count.index], "db_parameter_group", var.db_parameter_group))}"

  tags = "${merge(var.tags, map("Name", format("%s", lookup(var.read_replicas[count.index], "identifier"))))}"
}
