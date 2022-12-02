# Retrieve INSTANCE_ID 
INSTANCE_ID=`aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running \
    --query Reservations[0].Instances[0].InstanceId --output text`

# Stop Instance
aws ec2 stop-instances --instance-ids $INSTANCE_ID
