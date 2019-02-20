output "cluster_id" {
  value = "${aws_ecs_cluster.instance.id}"
}

output "instance_role" {
  value = "${aws_iam_role.instance.name}"
}
