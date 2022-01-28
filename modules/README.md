# Terraform Modules

> A curated help menu of terraform modules used in the project.

[<img src="https://github.com/theakshayraj/my-files/blob/main/file_type_terraform_icon_130125.png" align="right" width="600">](https://terraform.io)

[**Module 1**](#mod1): Autoscaling

[**Module 2**](#mod2): Application Load Balancer

[**Module 3**](#mod3): EFS

[**Module 4**](#mod4): Database

[**Module 5**](#mod5): Monitoring

[**Module 6**](#mod6): Network Configurations



<a id='mod1'></a>
## Module 1: Autoscaling

<a href="https://img.shields.io/badge/autoscaling-v4.1.0-%23c7c91c">
<img src="https://img.shields.io/badge/autoscaling-v4.1.0-%23c7c91c" /></a>

### Terraform module which creates autoscaling resources on AWS with launch template

<details>
  <summary><b>Variables</b></summary>
  
```
1. vpc_zone_identifier : Inputs a list of availability zones from network's 'security_group_asg' module
2. security_groups     : Inputs a list of security group ID's from network's 'security_group_id_asg' module
3. rds_endpt           : Inputs a string of RDS endpoint from db's 'rds_endpoint' output and passes it to userdata script   
4. target_group_arns   : Inputs a set of 'aws_alb_target_group' ARNs from alb's tg output
```
</details>

<details>
  <summary><b>Policies</b></summary>
  
  ```
  1. CloudwatchAgentServerPolicy.json: designated actions are "cloudwatch:PutMetricData","ec2:DescribeVolumes","ec2:DescribeTags","logs:PutLogEvents","logs:DescribeLogStreams",                                        "logs:DescribeLogGroups", "logs:CreateLogStream","logs:CreateLogGroup"
  2. assume_role_policy.json: designated action includes "AssumeRole"
  3. s3-policy.json: designated action is to "GetObject"
  
  ```
  </details>

<a id='mod2'></a>
## Module 2: Application Load Balancer

<a href="https://img.shields.io/badge/alb-v6.0.0-%238c66d9">
<img src="https://img.shields.io/badge/alb-v6.0.0-%238c66d9" /></a>

### Terraform module which creates Application load balancer on AWS

<details>
  <summary><b>Variables</b></summary>
  
```
1. vpc_id           : Inputs the VPC id where all resources will be deployed from networks's 'vpc_id_all' module
2. subnets          : Inputs a list of subnets to associate with the load balancer from network's 'public_sn_asg' module
3. security_groups  : Inputs a list of security group ID's from network's 'security_group_id_asg' module   
```
</details>



<details>
  <summary><b>Outputs</b></summary>
  
```
1. tg : module.alb.target_group_arns    #ARNs of the target groups passed onto scaling group
```
</details>


<a id='mod3'></a>
## Module 3: EFS

<a href="https://img.shields.io/badge/efs-v0.30.1-yellow">
<img src="https://img.shields.io/badge/efs-v0.30.1-yellow" /></a>

### Terraform module which creates EFS resource where it stores configuration files

<details>
  <summary><b>Variables</b></summary>
  
```
1. vpc_efs          : Inputs the VPC id where all resources will be deployed from networks's 'vpc_id_all' module
2. subnet_efs       : Inputs a list of subnets to associate with the load balancer from network's 'private_sn_asg' module
3. sec_group_efs    : Inputs a list of security group ID's from network's 'security_group_id_asg' module   
```
</details>



<details>
  <summary><b>Outputs</b></summary>
  
```
1. dns_name_efs : module.aws_efs.dns_name    #DNS of EFS
```
</details>


<a id='mod4'></a>
## Module 4: Database

<a href="https://img.shields.io/badge/terraform--aws--rds--source-v3.0.0-ff69b4">
<img src="https://img.shields.io/badge/terraform--aws--rds--source-v3.0.0-ff69b4" /></a>
<a href="https://img.shields.io/badge/terraform--aws--rds--read-v3.0.0-ad7521">
<img src="https://img.shields.io/badge/terraform--aws--rds--read-v3.0.0-ad7521" /></a>

### Terraform module which creates RDS resource on AWS and reads from it

<details>
  <summary><b>Variables</b></summary>
  
```
 1. vpc_asg
 2. sec_group_rds 
 3. subnet_rds
```
</details>

<details>
  <summary><b>Secrets manager</b></summary>

  We have used secret manager to store our secrets explicitly.To in order to use own secrets you can use the following keys.

```bash
| Secret-id          |   login-key      |  Pass-Key       |
|----------          |:-------------:   |------:          |
|drupal-login        |    username      |   pass          |
| drupal-master-key  |    master-user   |   masterpass    |
| sql-key            |    sql-user      |   sql-pass      |
```
  
   

</details>



<a id='mod5'></a>
## Module 5: Monitoring

<a href="https://img.shields.io/badge/prometheus-2.0.1-lightblue">
<img src="https://img.shields.io/badge/prometheus-2.0.1-lightblue" /></a>  
<a href="https://img.shields.io/badge/grafana-latest-lightgrey">
<img src="https://img.shields.io/badge/grafana-latest-lightgrey" /></a> 
<details>
  <summary><b>Variables</b></summary>
  
  ```
  1. subnet_monitoring_instance
  2. vpc_security_group_monitoring
  
  ```
  </details>
  
  <details>
  <summary><b>Policies</b></summary>
  
  ```
  1. assume_role_policy.json: designated Action has been to "AssumeRole" with acquired service "ec2.amazonaws.com"
  2. cw-policy.json: designated actions are "ListMetrics","GetMetricStatistics","GetMetricData"
  3. s3-policy.json:  designated actions are "PutObject", "GetObject" by S3 via Resource "aws:s3:::grafana-files-sg/*"
  ```
  </details>


<a id='mod6'></a>
## Module 6: Network Configurations

<a href="https://img.shields.io/badge/vpc-v3.2.0-red">
<img src="https://img.shields.io/badge/vpc-v3.2.0-red" /></a>
<a href="https://img.shields.io/badge/security__group__asg-v4.0.0-brightgreen">
<img src="https://img.shields.io/badge/security__group__asg-v4.0.0-brightgreen" /></a>
<a href="https://img.shields.io/badge/security__group__rds-v4.0.0-important">
<img src="https://img.shields.io/badge/security__group__rds-v4.0.0-important" /></a>

### Terraform module which create VPC, security groups for auto scaling groups and RDS on AWS

<details>
  <summary><b>Variables</b></summary>
 
  ```
  1.vpc_name             : Inputs the vpc name.
  2.security_groups     : Inputs a list of security group ID's from network's 'security_group_id_asg' module  
 
  ```
</details>


<details>
  <summary><b>Outputs</b></summary>
  
  ```
  1.vpc_id_all : #name of all vpc_id
  2.public_sn_asg : #all public subnets
  3.private_sn_asg :#all private subnets
  4.security_group_id_asg :#all security group id 
  5.security_group_id_rds :#all security group for rds

  ```
</details>


