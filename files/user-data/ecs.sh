#!/bin/bash
echo "ECS_CLUSTER=${ecs_cluster}" >> /etc/ecs/ecs.config

yum install -y aws-cli
aws s3 cp s3://${name}.${env}.ecs/nginx.conf /nginx.conf --region=${region}