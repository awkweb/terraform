data "aws_ecr_repository" "api" {
  name = "${var.name}-${var.env}/api"
}

data "aws_ecr_repository" "nginx" {
  name = "${var.name}-${var.env}/nginx"
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = "${data.aws_ecr_repository.api.name}"
  policy     = "${file("files/policies/ecr-lifecycle-policy.json")}"
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = "${data.aws_ecr_repository.nginx.name}"
  policy     = "${file("files/policies/ecr-lifecycle-policy.json")}"
}
