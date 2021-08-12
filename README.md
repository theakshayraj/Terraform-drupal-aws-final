
<img align="left" alt="Drupal Logo" src="https://www.drupal.org/files/Wordmark_blue_RGB.png" height="60px">
<img align="right" alt="Terraform" src="https://www.terraform.io/assets/images/logo-hashicorp-3f10732f.svg"  width="300">
<p align="center"><img align="middle" width="160" height="96" alt="AWS" src="https://user-images.githubusercontent.com/42437393/126828661-63749f56-2bd4-4447-9225-f41dd737025b.png"></p>
<br>

# Drupal Deployment on AWS using Terraform 

<p align="center">
<a href="https://img.shields.io/badge/drupal-v9.2.2-009cde">
<img src="https://img.shields.io/badge/drupal-v9.2.2-009cde" /></a>
  
<a href="https://img.shields.io/badge/aws-v3.37.0-FF9900">
<img src="https://img.shields.io/badge/aws-v3.37.0-FF9900" /></a> 
  
<a href="https://img.shields.io/badge/terraform-v0.15.0-844FBA">
<img src="https://img.shields.io/badge/terraform-v0.15.0-844FBA" /></a>

</p>
<br/>

**DRUPAL** :- Drupal is an open source content management platform supporting a variety of
websites ranging from personal weblogs to large community-driven websites. 

**TERRAFORM**:-Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.

**AWS**:- Deploying Drupal on AWS makes it easy to use AWS services to further enhance the performance and extend functionality of your content management framework.

**PACKER**:-Packer is a tool for building identical machine images for multiple platforms from a single source configuration.


The goal of this project is to host Drupal site on AWS via Terraform  it's a cross-platform, extensible tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

#### The different areas taken into account involves:
-  Application Load Balancer with Autoscaling 
-  Database Integration on RDS
-  Monitoring using Prometheus and Grafana

Also, a dedicated module named Network aims to provide desired information to implement all combinations of arguments supported by AWS and latest stable version of Terraform

## Steps and requirements for setting up your own Drupal Infrastructure with monitoring

- Sign up for AWS 
- Install Make 
```bash
  yum install make
```
- Install Packer
```bash
  yum install https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip
```
- Install Terraform
```bash
  yum install https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip
```

- Clone Repository
```
  git clone https://github.com/rahulttn/ttn-work.git
  git checkout drupal
  cd group-project
```

- Changes when using your own custom VPC
  - Switch to [drupal-custom-vpc](https://github.com/rahulttn/ttn-work/tree/drupal-custom-vpc) branch
    - Go to the [Network module variables.tf](https://github.com/rahulttn/ttn-work/blob/drupal-custom-vpc/group-project/modules/network/variables.tf)
      - This contains variable "vpc_new_id". Change its default value to your vpc id.  
    - Go to the [Network module main.tf](https://github.com/rahulttn/ttn-work/blob/drupal-custom-vpc/group-project/modules/network/main.tf)
      - Comment module "vpc" which creates a new vpc  
      - Make sure that data modules (vpc, subnet) are not commented
      
- Two ways for setting up the infrastructure
  - Using [Makefile](https://github.com/rahulttn/ttn-work/blob/drupal/group-project/Makefile)
  
    Additional requirements:
    
      - Intall make
      ```bash
        sudo yum install -y make
      ```
    Run the following commands in the order as given:
    
    ```
      make fix
      make validate
      make build
      make init # or run terraform init
      make plan # or run terraform plan
      make apply # or run terraform apply
      make destroy # or run terraform destroy
    ```
  
  - Using [terraform.sh](https://github.com/rahulttn/ttn-work/blob/drupal/group-project/terraform.sh) shell script
    
    No additional requirements
    
    Run the following commands in the order as given:
    
    ```
      sudo chmod +x terraform.sh
      ./terraform.sh fix
      ./terraform.sh validate
      ./terraform.sh build
      ./terraform.sh init # or run terraform init
      ./terraform.sh plan # or run terraform plan
      ./terraform.sh apply # or run terraform apply
      ./terraform.sh destroy # or run terraform destroy
    ```    
    
## AMI
- Packages used in AMI:

    ```
      1.) Git   
      2.) PHP   
      3.) MariaDB
      4.) Nginx
      5.) CloudWatch-agent  
      6.) Drupal 
    ```

## DRUPAL
Drupal login page installed using composer and drush.

#### Composer 
can be used to manage Drupal and all dependencies (modules, themes, libraries).
#### Drush 
Drush is a command line shell and Unix scripting interface for Drupal.


## MODULE WORKFLOW

- `make fix`:- This list down the errors and one may fix them via the file designed in a particular format
- `make validate`:- used to validate the syntax and configuration of a template. 
- `make build`:- takes a template and runs all the builds within it in order to generate a set of artifacts.
- `make init`:- used to initialize a working directory containing Terraform configuration files.
- `make plan`:- used to creates an execution plan. 
- `make apply`:- command executes the actions proposed in a Terraform plan.
- `make destroy`:- command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.

## MAKE Command: 
`make` command is used in order to "tell what to do". 
Herein we've been using `make` to running all commands with a single tool. Detailed usage is listed in the Makefile.

## Summary of Resources
-  1 VPC (Azs, Public and Private Subnets)
-  1 Application Load Balancer
-  3 Security Groups
-  2 Running Instance in ASG
-  1 Monitoring Instance
-  1 RDS in Private Subnet

## Contributors

|  Feature           | Contributor                                   |
| :------------- | :-------------------------------------------- |
| Drupal Deployment | [Digam Jain](https://github.com/digamjain), [Akshay Raj](https://github.com/theakshayraj) |
| Terraform Integration and Testing | [Akshay Raj](https://github.com/theakshayraj) |
| AMI Generation | [Manan Jain](https://github.com/manan3349), [Aahan Sharma](https://github.com/mkd63), [Akshay Raj](https://github.com/theakshayraj) |
| Monitoring module integration | [Aahan Sharma](https://github.com/mkd63) |
| IAM Policies and Roles | [Aahan Sharma](https://github.com/mkd63), [Manan Jain](https://github.com/manan3349) |
| DB module integration | [Akshay Raj](https://github.com/theakshayraj), [Digam Jain](https://github.com/digamjain) |
| Secret Manager Integration | [Akash Raturi](https://github.com/nutsbrainup), [Aahan Sharma](https://github.com/mkd63) |
| ASG module Integration | [Akshay Raj](https://github.com/theakshayraj), [Akash Raturi](https://github.com/nutsbrainup), [Digam Jain](https://github.com/digamjain) |
| Network module Integration | [Akshay Raj](https://github.com/theakshayraj) |
| Documentation | [Digam Jain](https://github.com/digamjain), [Silky](https://github.com/silky2001), [Riya Shrivastava](https://github.com/riyas2327) |



