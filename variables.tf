#
# Module: tf_aws_rds
#

# RDS Instance Variables

variable "rds_instance_identifier" {
    description = "Custom name of the instance"
}

variable "rds_is_multi_az" {
    description = "Set to true on production"
    default = "false"
}

variable "rds_storage_type" {
    description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
    default = "standard"
}

variable "rds_allocated_storage" {
    description = "The allocated storage in GBs"
    # You just give it the number, e.g. 10
}

variable "rds_engine_type" {
    # Valid types are
    # - mysql
    # - postgres
    # - oracle-*
    # - sqlserver-*
    # See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
    # --engine
}

variable "rds_engine_version" {
    # For valid engine versions, see:
    # See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
    # --engine-version

}

variable "rds_instance_class" {
    description = "Instance sizing"
    # Valid values
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
}

variable "database_name" {
    description = "The name of the database to create"
}

# Sefl-explainatory variables
variable "database_user" {}
variable "database_password" {}

variable "database_port" {}

# This is for a custom parameter to be passed to the DB
# We're "cloning" default ones, but we need to specify which should be copied
variable "db_parameter_group" {
    # default = "mysql5.6"
    default = "postgres9.5"
}

variable "publicly_accessible" {
    description = "If database can be publicly available (NOT recommended)"
    default = "false"
}

# RDS Subnet Group Variables
variable "subnets" {
    description = "List of subnets DB should be available at. It might be one subnet."
    type = "list"
}

variable "private_cidr" {
    description = "VPC private addressing, used for a security group"
    type = "string"
}

variable "rds_vpc_id" {
    description = "VPC to connect to, used for a security group"
    type = "string"
}