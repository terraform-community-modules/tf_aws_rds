# tf_aws_rds

# This module is deprecated and [terraform-aws-modules/terraform-aws-rds module](https://github.com/terraform-aws-modules/terraform-aws-rds) published on [the Terraform registry](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws) should be used instead.

## This repository will not have active support any more.

---

A Terraform Template for RDS

This module makes the following assumptions:
* You want your RDS instance in a VPC
* You have subnets in a VPC for two AZs
* Multi-AZ is optional.

## Input Variables

- `rds_instance_identifier` - Custom name of the DB instance (NOT a database name)
- `rds_is_multi_az` - Defaults to false. Set to true for a multi-az
  instance.
- `rds_storage_type` - Defaults to standard (magnetic)
- `rds_iops` - "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1', default is 0 if rds storage type is not io1"
- `rds_allocated_storage` - The number of GBs to allocate. Input must be an
  integer, e.g. `10`
- `rds_engine_type` - Engine type, such as `mysql` or `postgres`
- `rds_engine_version` - eg. `9.5.4` in case of postgres
- `rds_instance_class` - instance size, eg. `db.t2.micro`
- `database_name` - name of the dabatase
- `database_user` - user name (admin user)
- `database_password` - password - must be longer than 8 characters
- `db_parameter_group` - Defaults to `mysql5.6`, for postgres `postgres9.5`
- `use_external_parameter_group` - Defaults to `false`, if `true` use parameter group specified by `parameter_group_name` instead of a built-in one
- `parameter_group_name` - name of `aws_db_parameter_group` to use, if `use_external_parameter_group` is set
- `subnets` - List of subnets IDs in a list form, _e.g._ `["sb-1234567890", "sb-0987654321"]`
- `database_port` - Database port (needed for a security group)
- `publicly_accessible` - Defaults to `false`
- `private_cidr` - List of CIDR netblocks for database security group, _e.g._ `["10.0.1.0/24", "10.0.2.0/24]`
- `rds_vpc_id` - VPC ID DB will be connected to
- `allow_major_version_upgrade` - Allow upgrading of major version of database (eg. from Postgres 9.5.x to Postgres 9.6.x), default: false
- `auto_minor_version_upgrade` - Automatically upgrade minor version of the DB (eg. from Postgres 9.5.3 to Postgres 9.5.4), default: true
- `apply_immediately` - Specifies whether any database modifications are applied immediately, or during the next maintenance window, default: false
- `maintenance_window` - The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC, default: "Mon:03:00-Mon:04:00"
- `skip_final_snapshot` - if `true` (default), DB won't be backed up before deletion
- `copy_tags_to_snapshot` - copy all tags from RDS database to snapshot (default `true`)
- `backup_retention_period` - backup retention period in days (default: 0), must be `> 0` to enable backups
- `backup_window` - when to perform DB snapshot, default "22:00-03:00"; can't overlap with maintenance window
- `monitoring_interval` - To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60.
- `tags` - A mapping of tags to assign to the DB instance

## Outputs

- `rds_instance_id` - The ID of the RDS instance
- `rds_instance_address` - The Address of the RDS instance
- `subnet_group_id` - The ID of the Subnet Group

## Usage

You can use these in your terraform template with the following steps.

1.) If you define subnets as follows (it's an example of one might do that)
```
resource "aws_subnet" "example" {
    count = "${length(var.availability_zones)}"

    vpc_id = "${aws_vpc.public.id}"
    cidr_block = "10.0.${count.index}.0/24"
    map_public_ip_on_launch = true

    availability_zone = "${var.region}${element(var.availability_zones, count.index)}"

    tags {
        Name = "${var.region}${element(var.availability_zones, count.index)}"
    }
}
```

From `availability_zones` and `region` variables defined as follows:
```

variable "region" {
    type = "string"
    default = "eu-central-1"
}

variable "availability_zones" {
    type = "list"
    default = ["a", "b"]
}
```

You will also need CIDR:
```
variable "private_cidr" {
    type = "list"
    default = ["10.0.0.0/16"]
}
```

2.) Adding a module resource to your template, e.g. `main.tf`

```
module "my_rds_instance" {
  source = "github.com/terraform-community-modules/tf_aws_rds"

    # RDS Instance Inputs
    rds_instance_identifier = "${var.rds_instance_identifier}"
    rds_allocated_storage = "${var.rds_allocated_storage}"
    rds_engine_type = "${var.rds_engine_type}"
    rds_instance_class = "${var.rds_instance_class}"
    rds_engine_version = "${var.rds_engine_version}"
    db_parameter_group = "${var.db_parameter_group}"

    database_name = "${var.database_name}"
    database_user = "${var.database_user}"
    database_password = "${var.database_password}"
    database_port = "${var.database_port}"

    # Upgrades
    allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
    auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"

    apply_immediately           = "${var.apply_immediately}"
    maintenance_window          = "${var.maintenance_window}"

    # Snapshots and backups
    skip_final_snapshot   = "${var.skip_final_snapshot}"
    copy_tags_to_snapshot = "${var.copy_tags_to_snapshot}"

    # DB Subnet Group Inputs
    subnets = ["${aws_subnet.example.*.id}"] # see above
    rds_vpc_id = "${module.vpc}"
    private_cidr = ["${var.private_cidr}"]

    tags {
        terraform = "true"
        env       = "${terraform.env}"
    }
}
```

2.) Setting values for the following variables, either through `terraform.tfvars` or `-var` arguments on the CLI

- `rds_instance_identifier`
- `rds_is_multi_az`
- `rds_storage_type`
- `rds_iops`
- `rds_allocated_storage`
- `rds_engine_type`
- `rds_engine_version`
- `rds_instance_class`
- `database_name`
- `database_user`
- `database_password`
- `db_parameter_group`
- `subnets`
- `database_port`
- `publicly_accessible`
- `private_cidr`
- `rds_vpc_id`
- `allow_major_version_upgrade`
- `auto_minor_version_upgrade`
- `apply_immediately`
- `maintenance_window`
- `skip_final_snapshot`
- `copy_tags_to_snapshot`
- `backup_retention_period`
- `backup_window`
- `monitoring_interval`
- `tags`

# Maintainers

* [Brandon Burton](https://github.com/solarce) (brandon@inatree.org) **Creator**
* [Anton Babenko](https://github.com/antonbabenko)
* [Steve Huff](https://github.com/hakamadare)

# Contributors

* [Grzegorz Adamowicz](https://github.com/gstlt)
* [Trung Nguyen](https://github.com/trungnguyen)
* [Marek Kwasecki](https://github.com/kwach)
* [Kevin Duane](https://github.com/crackmac)
* [Keith Grennan](https://github.com/keeth)
* [Lee Provoost](https://github.com/leeprovoost)
* Vikas Sakode
* Carina Digital
* [Bill Wang](https://github.com/ozbillwang)
* [Robin Bowes](https://github.com/robinbowes)

# License

Apache 2 Licensed. See LICENSE for full details.
