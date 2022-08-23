provider "aws" {
    access_key = "eenfowenoewfpewm3fejsdc"
    secret_key = "sfowenfciefklfnnowejckcneinfipewjf"
    region = "us-east-1"
}

module "project1" {
  source = "./modules/vpc"
  vpcname = "DevOpsTest"
  igwname = "DevOpsTest-IGW"
}

module "project2" {
  source = "./modules/vpc"
  vpcname = "DevOpsTest2"
  igwname = "DevOpsTest2-IGW"
}

module "project3" {
  source = "./modules/vpc"
  vpcname = "DevOpsTest3"
  igwname = "DevOpsTest3-IGW"
}

# terraform init