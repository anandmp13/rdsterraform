
##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}
	
data "aws_db_snapshot" "db_snapshot" {
    most_recent = true
    db_snapshot_identifier = "arn:aws:rds:us-east-1:480032581074:snapshot:mydemodb"
}


#####
# DB
#####
module "db" {
  source = "../../"

  identifier = "demodb"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<accound id>:key/<kms key id>"
  name     = "demodb"
  username = "test"
  password = "password"
  port     = "3306"

  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"


  snapshot_identifier        = "arn:aws:rds:us-east-1:480032581074:snapshot:mydemodb"

  multi_az = false

  # disable backups to create DB faster
  backup_retention_period    = 7
  backup_window              = "23:00-23:45"
  auto_minor_version_upgrade = "true"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }


  enabled_cloudwatch_logs_exports = ["audit", "general"]

  # DB subnet group
  subnet_ids = ["${data.aws_subnet_ids.all.ids}"]

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"



  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = false

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
