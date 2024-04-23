#!/bin/bash
# This script should be cronjobed to run every minute to monitor the PM2 metrics e.g */1 * * * * /home/ubuntu/tech-blog-fullstack/monitoring.sh
# Get the metrics from the PM2 metrics 

metrics=$(curl -s "localhost:9209/metrics")

# Extract the metrics from the response
# Important: Id="0" should be "sean-conroy-blog"
pm2_cpu=$(echo "$metrics" | grep 'pm2_cpu{id="0"' | awk '{print $NF}')
pm2_memory=$(echo "$metrics" | grep 'pm2_memory{id="0"' | awk '{print $NF}')
pm2_used_heap_size=$(echo "$metrics" | grep 'pm2_used_heap_size{id="0"' | awk '{print $NF}')
pm2_heap_usage=$(echo "$metrics" | grep 'pm2_heap_usage{id="0"' | awk '{print $NF}')
pm2_heap_size=$(echo "$metrics" | grep 'pm2_heap_size{id="0"' | awk '{print $NF}')
pm2_active_requests=$(echo "$metrics" | grep 'pm2_active_requests{id="0"' | awk '{print $NF}')


# System metrics   
USEDMEMORY=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')
USEDCPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')



# Get the instance ID
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

# Adding the PM2 metrics to CloudWatch
aws cloudwatch put-metric-data --metric-name "Pm2 cpu-usage" --dimensions Instance=$INSTANCE_ID --namespace "PM2 Proudction Blog" --value $pm2_cpu --unit Percent -- storage-resolution 1
aws cloudwatch put-metric-data --metric-name "Pm2 memory-usage" --dimensions Instance=$INSTANCE_ID --namespace "PM2 Proudction Blog" --value $pm2_memory --unit Bytes  -- storage-resolution 1
aws cloudwatch put-metric-data --metric-name "Pm2 active-requests" --dimensions Instance=$INSTANCE_ID --namespace "PM2 Proudction Blog" --value $pm2_active_requests --unit Count  -- storage-resolution 1
aws cloudwatch put-metric-data --metric-name "Pm2 used-heap-size" --dimensions Instance=$INSTANCE_ID --namespace "PM2 Proudction Blog" --value $pm2_used_heap_size --unit Bytes
aws cloudwatch put-metric-data --metric-name "Pm2 heap-usage" --dimensions Instance=$INSTANCE_ID --namespace  "PM2 Proudction Blog" --value $pm2_heap_usage --unit Percent
aws cloudwatch put-metric-data --metric-name "Pm2 heap-size" --dimensions Instance=$INSTANCE_ID --namespace "PM2 Proudction Blog" --value $pm2_heap_size --unit Bytes

# Adding the system metrics to CloudWatch
aws cloudwatch put-metric-data --metric-name "system cpu-usage" --dimensions Instance=$INSTANCE_ID --namespace "System Production Blog" --value $USEDCPU --unit Percent
aws cloudwatch put-metric-data --metric-name "system memory-usage" --dimensions Instance=$INSTANCE_ID --namespace "System Production Blog" --value $USEDMEMORY --unit Percent

current_time=$(date '+%Y-%m-%d %H:%M')
echo "( $current_time )The metrics have been added to CloudWatch..." >> ~/log.txt
