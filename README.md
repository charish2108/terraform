# Terraform
Terraform Null Resource
If you need to run provisioners that aren't directly associated with a specific resource, you can associate them with a null_resource.

Creating an EC2 instance using Terraform and copying a local file into /tmp/script.sh. if local file gets updated then copied file which now lies in EC2 should also get updated without creating multiple resources.
