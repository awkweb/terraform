output "cluster_name" {
  value = "${aws_ecs_cluster.instance.name}"
}

output "instance_role" {
  value = "${aws_iam_role.instance.name}"
}
