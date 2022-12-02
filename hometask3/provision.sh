# Retrieve default VPC ID
VPC_ID=`aws ec2 describe-vpcs --query Vpcs[0].VpcId --output text`

# Retrieve default SubNet ID
SUBNET_ID=`aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text`

# Create security group with rule to allow SSH
GROUP_ID=`aws ec2 create-security-group \
    --group-name SecurityGroup \
    --description "Security group" \
    --vpc-id $VPC_ID \
    --query GroupId --output text`

# Authorize security group
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 

# Create a key pair and output to MyKeyPair.pem
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > ./MyKeyPair.pem

# Modify permissions
chmod 400 MyKeyPair.pem

# Create a script to install the Apache server
echo '#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd' > user_script.sh

# Modify VPC attribute
aws ec2 modify-vpc-attribute --enable-dns-hostnames --vpc-id $VPC_ID 

# Run Instance
INSTANCE_ID=`aws ec2 run-instances \
    --image-id ami-0533f2ba8a1995cf9 \
    --count 1 \
    --instance-type t2.micro \
    --key-name MyKeyPair \
    --security-group-ids $GROUP_ID \
    --subnet-id $SUBNET_ID \
    --user-data file://user_script.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Role,Value=WebServer}]' \
    --query Instances[0].InstanceId --output text`

# Retrieve IP address
IP_ADDRESS=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --query Reservations[0].Instances[0].PublicDnsName --output text`
echo $IP_ADDRESS

