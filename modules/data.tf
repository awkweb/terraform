data "aws_acm_certificate" "instance" {
  domain = "*.wilbur.app"
}

data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["amazon"]
}

data "aws_route53_zone" "instance" {
  name = "wilbur.app."
}
