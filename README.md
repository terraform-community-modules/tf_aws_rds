tf_aws_rds
==========
A Terraform Template for RDS

This module makes the following assumptions:
* You want your RDS instance in a VPC
* You have subnets in a VPC for two AZs
* Multi-AZ is optional.

Input Variables
---------------

- `rds_instance_name`
- `rds_is_multi_az` - Defaults to false. Set to true for a multi-az
  instance.
- `rds_storage_type` - Defaults to standard (magnetic)
- `rds_allocated_storage` - The number of GBs to allocate. Input must be an
  integer, e.g. `10`
- `rds_engine_type` - Engine type, such as `mysql` or `postgres`
- `rds_engine_version`
- `rds_instance_class`
- `database_name`
- `database_user`
- `database_password`
- `db_parameter_group` - Defaults to "default.mysql5.6"
- `rds_security_group_id` - The ID of the security group you create for
  your RDS instance.
- `subnet_az1` - The VPC subnet ID for AZ1
- `subnet_az2` - The VPC subnet ID for AZ2
- `aws_access_key`
- `aws_secret_key`
- `aws_region`

Outputs
-------

- `launch_config_id`
- `asg_id`

Usage
-----

You can use these in your terraform template with the following steps.

1.) Adding a module resource to your template, e.g. `main.tf`

```
module "my_rds_instance" {
  source = "github.com/terraform-community-modules/tf_aws_rds"

  //RDS Instance Inputs
  rds_instance_name = "${var.rds_instance_name}"
  rds_allocated_storage = "${var.rds_allocated_storage}"
  rds_engine_type = "${var.rds_engine_type}"
  rds_engine_version = "${var.rds_engine_version}"
  database_name = "${var.database_name}"
  database_user = "${var.database_user}"
  database_password = "${var.database_password}"
  rds_security_group_id = "${var.rds_security_group_id}"
  db_parameter_group = "${var.db_parameter_group}"

  // DB Subnet Group Inputs
  subnet_az1 = "${var.subnet_az1}"
  subnet_az2 = "${var.subnet_az2}"

  // AWS Provider Inputs
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.aws_region}"
}
```

2.) Setting values for the following variables, either through
`terraform.tfvars` or `-var` arguments on the CLI

- aws_access_key
- aws_secret_key
- aws_region
- rds_instance_name
- rds_allocated_storage
- rds_engine_type
- rds_engine_version
- database_name
- database_user
- database_password
- rds_security_group_id
- db_parameter_group
- subnet_az1
- subnet_az2

Authors
=======

Created and maintained by [Brandon Burton](https://github.com/solarce)
(brandon@inatree.org).

License
=======

Apache 2 Licensed. See LICENSE for full details.
