provider "aws" {
    access_key = "eenfowenoewfpewm3fejsdc"
    secret_key = "sfowenfciefklfnnowejckcneinfipewjf"
    region = "us-east-1"
}

module "project1" {
  # source = "./modules/vpc"   # github repo path where main.rf and variable.tf live
  source = "github.com/charish2108/terraform/tree/main/modules/vpc"
  vpcname = "DevOpsTest"
  igwname = "DevOpsTest-IGW"
}

module "project2" {         
  # source = "./modules/vpc"  # using GitHub SSH
  # source = "git@github.com:charish2108/terraform.git" # Private key should be added for this
  source = "github.com/charish2108/terraform/tree/main/modules/vpc"
  vpcname = "DevOpsTest2"
  igwname = "DevOpsTest2-IGW"
}

module "project3" {
  # source = "./modules/vpc"  # github repo path where main.rf and variable.tf live
  source = "github.com/charish2108/terraform/tree/main/modules/vpc"
  vpcname = "DevOpsTest3"
  igwname = "DevOpsTest3-IGW"
}

# terraform init
# terraform plan
# terraform apply --auto-approve