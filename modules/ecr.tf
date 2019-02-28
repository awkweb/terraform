resource "aws_ecr_lifecycle_policy" "policy" {
  repository = "${data.aws_ecr_repository.api.name}"
  policy     = "${file("files/policies/ecr-lifecycle-policy.json")}"
}
