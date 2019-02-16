output "repository_url" {
  value = "${aws_ecr_repository.nginx.repository_url}"
}

output "service_name" {
  value = "${aws_ecs_service.nginx.name}"
}
