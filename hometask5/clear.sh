# Retrieve TOPIC_ARN
TOPIC_ARN=`aws sns list-topics --query 'Topics[*].TopicArn' --output text`

# Delete Topic
aws sns delete-topic --topic-arn $TOPIC_ARN

# Retrieve AlarmName
ALARM_NAME=`aws cloudwatch describe-alarms --query 'MetricAlarms[*].AlarmName' --output text`

# Delete Alarm
aws cloudwatch delete-alarms --alarm-names $ALARM_NAME