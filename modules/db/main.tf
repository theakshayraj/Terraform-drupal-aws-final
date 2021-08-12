
locals {
  name = "complete-mysql"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

resource "random_password" "master_user" {
  length           = 6
  number           = false
  special          = false
  override_special = "_%@"
}
resource "random_password" "master_password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "random_password" "drupal_user" {
  length           = 6
  number           = false
  special          = false
  override_special = "_%@"
}
resource "random_password" "drupal_password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "random_password" "sql_user" {
  length           = 6
  special          = false
  number           = false
  override_special = "_%@"
}
resource "random_password" "sql_password" {
  length           = 16
  special          = false
  override_special = "_%@"
}



module "secretsmanager" {

  source = "lgallard/secrets-manager/aws"

  secrets = [
   {
      name        = "${terraform.workspace}-rdscredentials"
      description = "This is credential for rds instance"
      secret_key_value = {
        user = random_password.master_user.result
        pass = random_password.master_password.result
      }
      recovery_window_in_days = 0
    },
    {
      name        = "${terraform.workspace}-drupalcredentials"
      description = "Credential for drupal"
      secret_key_value = {
        user = random_password.drupal_user.result
        pass = random_password.drupal_password.result
      }
      recovery_window_in_days = 0
    },
    {
      name        = "${terraform.workspace}-sqlcredentials"
      description = "Credential for sql db"
      secret_key_value = {
        user = random_password.sql_user.result
        pass = random_password.sql_password.result
      }
      recovery_window_in_days = 0
    },
 ]

  tags = {
    Environment = "dev"
    Terraform   = true
  }

}

data "aws_secretsmanager_secret" "master_db_secrets" {
  arn = module.secretsmanager.secret_arns[0]
}

data "aws_secretsmanager_secret_version" "current_master" {
  secret_id = data.aws_secretsmanager_secret.master_db_secrets.id
}

data "aws_secretsmanager_secret" "drupal_secrets" {
  arn = module.secretsmanager.secret_arns[1]
}

data "aws_secretsmanager_secret_version" "current_drupal" {
  secret_id = data.aws_secretsmanager_secret.drupal_secrets.id
}

data "aws_secretsmanager_secret" "sql_secrets" {
  arn = module.secretsmanager.secret_arns[2]
}

data "aws_secretsmanager_secret_version" "current_sql" {
  secret_id = data.aws_secretsmanager_secret.sql_secrets.id
}


module "terraform-aws-rds-source" {
  #source = "git@github.com:terraform-aws-modules/terraform-aws-rds.git?ref=v3.0.0"
  
  source  = "terraform-aws-modules/rds/aws"
  version = "3.0.0"
  # depends_on = [
  #   data.aws_secretsmanager_secret_version.current.secret_string
  # ]

  identifier = "${terraform.workspace}-mysql-drupal"

  engine         = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.medium"

  allocated_storage     = 50
  max_allocated_storage = 100

  name     = "mydb_source"
  username = jsondecode(data.aws_secretsmanager_secret_version.current_master.secret_string)["user"]
  password = jsondecode(data.aws_secretsmanager_secret_version.current_master.secret_string)["pass"]
  port     = 3306

  parameter_group_name      = "default.mysql5.7"
  create_db_parameter_group = false
  create_db_option_group    = false

  maintenance_window = "Sun:05:00-Sun:06:00"
  backup_window      = "09:46-10:16"
  delete_automated_backups = true

  #backup_retention_period = 10
  skip_final_snapshot     = true

  subnet_ids             = var.subnet_rds
  vpc_security_group_ids = [var.sec_group_rds]
}

output "rds_endpoint" {
  value = module.terraform-aws-rds-source.db_instance_endpoint
}

output "drupal_user" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current_drupal.secret_string)["user"]
}

output "drupal_pass" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current_drupal.secret_string)["pass"]
}

output "sql_user" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current_sql.secret_string)["user"]
}

output "sql_pass" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current_sql.secret_string)["pass"]
}


output "master_user" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current_master.secret_string)["user"]
}

output "master_pass" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current_master.secret_string)["pass"]
}    
