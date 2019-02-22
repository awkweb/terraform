resource "aws_key_pair" "instance" {
  key_name   = "${var.name}-${var.env}"
  public_key = "${file("wilbur.pub")}"
}

resource "aws_launch_configuration" "instance" {
  name                 = "${var.name}-${var.env}-lc"
  image_id             = "${data.aws_ami.ecs_optimized.image_id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2.name}"
  user_data            = "${data.template_file.user_data.rendered}"

  security_groups = [
    "${aws_security_group.api.id}",
    "${aws_security_group.db_access.id}",
  ]

  key_name = "${aws_key_pair.instance.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_s3_bucket.ecs"]
}

resource "aws_autoscaling_group" "instance" {
  name                 = "${var.name}-${var.env}-asg"
  launch_configuration = "${aws_launch_configuration.instance.name}"

  max_size            = "${var.asg_max_size}"
  min_size            = "${var.asg_min_size}"
  desired_capacity    = "${var.asg_desired_size}"
  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]

  lifecycle {
    create_before_destroy = true
  }
}
