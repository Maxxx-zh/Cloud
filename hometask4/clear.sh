# Retrieve LoadBalancer ARN
LB_ARN=`aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text`
echo $LB_ARN

# Retrieve AutoScalingGroup ARN
ASG_ARN=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].AutoScalingGroupARN' --output text`

# Retrieve TargetGroup ARN
TG_ARN=`aws elbv2 describe-target-groups --query 'TargetGroups[*].TargetGroupArn' --output text`

# # Delete AutoScalingGroup 
# aws autoscaling delete-auto-scaling-group \
#     --auto-scaling-group-name AutoScalingGroup

# Delete LoadBalancer by ARN
aws elbv2 delete-load-balancer \
    --load-balancer-arn $LB_ARN

# Delete TargetGroup
aws elbv2 delete-target-group \
    --target-group-arn $TG_ARN

# Sleep for 20 sec
sleep 20

# Delete Security Group for Instances
aws ec2 delete-security-group --group-name SecurityGroupINC

# Delete Security Group LB
aws ec2 delete-security-group --group-name SecurityGroupLB
