# tf_aws_rds

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
- `rds_allocated_storage` - The number of GBs to allocate. Input must be an
  integer, e.g. `10`
- `rds_engine_type` - Engine type, such as `mysql` or `postgres`
- `rds_engine_version` - eg. `9.5.4` in case of postgres
- `rds_instance_class` - instance size, eg. `db.t2.micro`
- `database_name` - name of the dabatase
- `database_user` - user name (admin user)
- `database_password` - password - must be longer than 8 characters
- `db_parameter_group` - Defaults to `mysql5.6`, for postgres `postgres9.5`
- `subnets` - List of subnets IDs in a list form, eg. `["sb-1234567890", "sb-0987654321"]`
- `database_port` - Database port (needed for a security group)
- `publicly_accessible` - Defaults to `false`
- `private_cidr` - CIDR for database security group, eg 10.0.0.0/16
- `rds_vpc_id` - VPC ID DB will be connected to

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
    map_public_ip_on_launch = "true"

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
    type = "string"
    default = "10.0.0.0/16"
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

    # DB Subnet Group Inputs
    subnets = ["${aws_subnet.example.*.id}"] # see above
    rds_vpc_id = "${module.vpc}"
    private_cidr = "${var.private_cidr}"
}
```

2.) Setting values for the following variables, either through
`terraform.tfvars` or `-var` arguments on the CLI

- `rds_instance_identifier`
- `rds_is_multi_az`
- `rds_storage_type`
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


# Authors

Created and maintained by [Brandon Burton](https://github.com/solarce)
(brandon@inatree.org).

# Contributors

* [Grzegorz Adamowicz](https://github.com/gstlt)

# License

Apache 2 Licensed. See LICENSE for full details.
