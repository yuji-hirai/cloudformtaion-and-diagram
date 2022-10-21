# EC2-IDとアカウントIDを修正すること

METRICS=`aws cloudwatch get-metric-data --region ap-northeast-1 \
  --metric-data-queries '{"Id":"q1","MetricStat":{"Metric":{"Namespace":"AWS/EC2","MetricName":"CPUUtilization","Dimensions":[{"Name":"InstanceId","Value":"i-04e1dd25eeb674d26"}]},"Period":60,"Stat":"Average"}}' \
  --start-time $(date --utc "+%Y-%m-%dT%H:%M:01Z" -d "2 min ago") \
  --end-time $(date --utc "+%Y-%m-%dT%H:%M:%SZ") \
  --query 'MetricDataResults[0]' --output json`

aws sns publish --region ap-northeast-1 \
  --topic-arn "arn:aws:sns:ap-northeast-1:586569454024:task2-sns" \
  --message "$METRICS"