# Create SNS topic
TOPIC_ARN=`aws sns create-topic --name health_checking --query 'TopicArn' --output text`

# Subscribe SNS topic
SUB_ARN=`aws sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol email \
    --notification-endpoint maksymzhytnikov@gmail.com \
    --query 'SubscriptionArn' --output text`

# Set up a cloudwatch
aws cloudwatch put-metric-alarm \
    --alarm-name health_checking \
    --alarm-description "Instance is deleted!" \
    --metric-name HealthyHostCount \
    --namespace AWS/ApplicationELB \
    --statistic Average \
    --period 60 \
    --threshold 2 \
    --comparison-operator LessThanThreshold \
    --dimensions Name=TargetGroup,Value=targetgroup/TargetGroup/4e279f551da88b47 Name=LoadBalancer,Value=app/my-load-balancer/c5f864f60c4c2f9d \
    --evaluation-periods 1 \
    --alarm-actions $TOPIC_ARN