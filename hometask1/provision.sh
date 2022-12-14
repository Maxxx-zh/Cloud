#!/bin/bash

aws s3api create-bucket --bucket maksyms3bucket --region us-east-1                              # 🪄 Create a bucket from CLI

aws s3api put-bucket-policy --bucket maksyms3bucket --policy file://bucket_policy.json          # 👮🏼‍♀️ Add Bucket Policy

aws s3 sync ./ s3://maksyms3bucket/                                                             # 🔮 Upload files on S3 bucket

aws s3 website s3://maksyms3bucket/ --index-document index.html --error-document error.html     # ⚙️ Configure a website

# Website URL: http://maksyms3bucket.s3-website-us-east-1.amazonaws.com                           