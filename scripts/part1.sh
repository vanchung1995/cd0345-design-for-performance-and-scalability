# move to folder part1
cd Exercise_1

# init terraform
terraform init

# plan
terraform plan

# apply 
terraform apply

# delete 2 m4 instance
terraform destroy -target=aws_instance.m4large_ec2
