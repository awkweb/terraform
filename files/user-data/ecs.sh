#!/bin/bash
yum update -y -q
echo "ECS_CLUSTER=${ecs_cluster}" >> /etc/ecs/ecs.config
