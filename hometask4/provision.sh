# Retrieve default VPC ID
VPC_ID=`aws ec2 describe-vpcs --query Vpcs[0].VpcId --output text`

# Retrieve default SubNet ID
SUBNET_1_ID=`aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text`
SUBNET_2_ID=`aws ec2 describe-subnets --query 'Subnets[1].SubnetId' --output text`

# Create security group for LoadBalancer
GROUP_LB_ID=`aws ec2 create-security-group \
    --group-name SecurityGroupLB \
    --description "Security group for LB" \
    --vpc-id $VPC_ID \
    --query GroupId --output text`

# Configure the security group for LoadBalancer
aws ec2 authorize-security-group-ingress --group-id $GROUP_LB_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 

# Create LoadBalancer
LB_ARN=`aws elbv2 create-load-balancer \
    --name my-load-balancer \
    --subnets $SUBNET_1_ID $SUBNET_2_ID \
    --security-groups $GROUP_LB_ID \
    --query LoadBalancers[*].LoadBalancerArn --output text`

# Retrieve VPC IP Address
VPC_NET=`aws ec2 describe-vpcs --query Vpcs[0].CidrBlock --output text`

# Create security group for Instances
GROUP_INC_ID=`aws ec2 create-security-group \
    --group-name SecurityGroupINC \
    --description "Security group for Instances" \
    --vpc-id $VPC_ID \
    --query GroupId --output text`

# Configure Security Group to allow incoming trafic only from Load Balancer
aws ec2 authorize-security-group-ingress --group-id $GROUP_INC_ID --protocol tcp --port 80 --cidr $VPC_NET
aws ec2 authorize-security-group-ingress --group-id $GROUP_INC_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# Create a key pair and output to MyKeyPair.pem
aws ec2 create-key-pair --key-name MyKeyPairLB --query 'KeyMaterial' --output text > ./MyKeyPairLB.pem

# Modify permissions
chmod 400 MyKeyPairLB.pem

# Retrieve IMAGE_ID
IMAGE_ID=`aws ec2 describe-images --owners 296531772601 --query Images[0].ImageId --output text`

# Create Instances
INSTANCE_1_ID=`aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --subnet-id $SUBNET_1_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name MyKeyPairLB \
    --security-group-ids $GROUP_INC_ID \
    --user-data file://user_data.sh \
    --query Instances[0].InstanceId --output text`

INSTANCE_2_ID=`aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --subnet-id $SUBNET_2_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name MyKeyPairLB \
    --security-group-ids $GROUP_INC_ID \
    --user-data file://user_data.sh \
    --query Instances[0].InstanceId --output text`

# Create a Target Group
TG_ARN=`aws elbv2 create-target-group \
    --name TargetGroup \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --query 'TargetGroups[*].TargetGroupArn' --output text`

# Sleep for 30 sec
sleep 30

# Register Targets
aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=$INSTANCE_1_ID Id=$INSTANCE_2_ID

# Create Listener
aws elbv2 create-listener \
    --load-balancer-arn $LB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN 

# Create Autoscaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name AutoScalingGroup \
    --instance-id $INSTANCE_1_ID \
    --min-size 2 \
    --max-size 2 \
    --target-group-arns $TG_ARN 

# Update health settings
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name AutoScalingGroup \
    --health-check-type ELB \
    --health-check-grace-period 15 

# Retrieve LoadBalancer's DNS
LB_DNS=`aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text`

# Check AutoScalingGroup
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name AutoScalingGroup

# Pring LoadBalancer DNS
echo $LB_DNS

# Connect to instance using key pair and public IP
# ssh -i "MyKeyPairLB.pem" ec2-user@

# How to write using NANO
# https://www.freecodecamp.org/news/how-to-save-and-exit-nano-in-terminal-nano-quit-command/