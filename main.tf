module "db" {
  source        = "./modules/db/"
  vpc_asg       = module.network.vpc_id_all
  sec_group_rds = module.network.security_group_id_rds
  subnet_rds    = module.network.private_sn_asg
}

module "asg" {
  source        = "./modules/asg/"
  subnet_asg    = module.network.public_sn_asg
  sec_group_asg = module.network.security_group_id_asg
  rds_point     = module.db.rds_endpoint
  drupal_user   = module.db.drupal_user
  drupal_pass   = module.db.drupal_pass
  sql_user      = module.db.sql_user
  sql_pass      = module.db.sql_pass
  master_user   = module.db.master_user
  master_pass   = module.db.master_pass 
  depends_on    = [module.db.rds_endpoint,module.db.drupal_user,module.db.drupal_pass,module.db.sql_user,module.db.sql_pass]
  target_gp     = module.alb.tg
  img_id        = data.aws_ami.packer_ami.id
  dns_name      = module.efs.dns_name_efs
}

module "network" {
  source = "./modules/network/"
}

module "efs" {
  source        = "./modules/efs/"
  subnet_efs    = module.network.private_sn_asg
  sec_group_efs = module.network.security_group_id_asg
  vpc_efs       = module.network.vpc_id_all
}

module "alb" {
  source        = "./modules/alb/"
  vpc_alb       = module.network.vpc_id_all
  sec_group_alb = module.network.security_group_id_asg
  subnet_alb    = module.network.public_sn_asg
}

module "monitoring" {
  source = "./modules/monitoring/"
  lb_dns     = module.alb.dns
  depends_on    = [module.alb.dns]
  subnet_monitoring_instance = module.network.public_sn_asg[0]
  vpc_security_group_monitoring = module.network.security_group_id_asg
}

data "aws_ami" "packer_ami" {
  most_recent = true
  owners = ["self"]
  name_regex = "^packer*"

  # filter {
  #   name   = "packer-*"
  #   values = ["available"]
  # }
}
