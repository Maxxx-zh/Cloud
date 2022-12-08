# Delete stack
aws cloudformation delete-stack --stack-name sam-app

# Delete a Role
aws iam delete-role --role-name lambda-s3-role

# Clearing source bucket
aws s3 rm s3://sourcebucketlab8 --recursive

# Clearing destination bucket
aws s3 rm s3://sourcebucketlab8-resized --recursive

# Remove source bucket
aws s3 rb s3://sourcebucketlab8

# Remove destination bucket
aws s3 rb s3://sourcebucketlab8-resized
