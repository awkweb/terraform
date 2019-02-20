resource "aws_ecs_cluster" "instance" {
  name = "${var.name}"
}

resource "aws_iam_role" "instance" {
  name = "${var.name}-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = "${aws_iam_role.instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = "${aws_iam_role.instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.name}-instance-profile"
  role = "${aws_iam_role.instance.name}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.instance.name}"
  }
}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "user" {
  key_name   = "${var.name}"
  public_key = "${file("wilbur.pub")}"
}

resource "aws_launch_configuration" "instance" {
  name_prefix          = "${var.name}-lc"
  image_id             = "${data.aws_ami.ecs.id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.instance.name}"
  user_data            = "${data.template_file.user_data.rendered}"
  security_groups      = ["${var.security_groups_ids}"]
  key_name             = "${aws_key_pair.user.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.name}-asg"

  launch_configuration = "${aws_launch_configuration.instance.name}"
  vpc_zone_identifier  = ["${var.vpc_subnets}"]
  max_size             = "${var.asg_max_size}"
  min_size             = "${var.asg_min_size}"
  desired_capacity     = "${var.asg_desired_size}"

  lifecycle {
    create_before_destroy = true
  }
}
