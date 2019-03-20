resource "aws_key_pair" "instance" {
  key_name   = "${var.name}-${var.env}"
  public_key = "${file("butter.pub")}"
}

resource "aws_launch_configuration" "ecs" {
  name                 = "${var.name}-${var.env}-ecs-lc"
  image_id             = "${data.aws_ami.ecs_optimized.image_id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2.name}"
  user_data            = "${data.template_file.user_data_ecs.rendered}"

  security_groups = [
    "${aws_security_group.db_access.id}",
    "${aws_security_group.api.id}",
  ]

  key_name = "${aws_key_pair.instance.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_s3_bucket.api_assets", "aws_instance.bastion"]
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "${var.name}-${var.env}-ecs-asg"
  launch_configuration = "${aws_launch_configuration.ecs.name}"

  max_size            = "${var.asg_max_size}"
  min_size            = "${var.asg_min_size}"
  desired_capacity    = "${var.asg_desired_size}"
  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    key                 = "Name"
    value               = "${var.name}-${var.env}-ecs"
    propagate_at_launch = true
  }
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.bastion.id}"
  instance_type = "t2.nano"
  key_name      = "${aws_key_pair.instance.key_name}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  user_data     = "${data.template_file.user_data_bastion.rendered}"

  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "${var.name}-${var.env}-bastion"
  }

  provisioner "file" {
    source      = "butter.pem"
    destination = "/home/ec2-user/.ssh/butter.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("butter.pem")}"
      timeout     = "5m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0400 /home/ec2-user/.ssh/*.pem",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("butter.pem")}"
    }
  }
}

# resource "aws_ami_from_instance" "bastion" {
#   name               = "ami-terraform-generated-bastion"
#   source_instance_id = "${aws_instance.bastion.id}"
# }


# resource "aws_launch_configuration" "bastion" {
#   name          = "${var.name}-${var.env}-bastion-lc"
#   image_id      = "${aws_ami_from_instance.bastion.id}"
#   instance_type = "t2.nano"
#   user_data     = "${data.template_file.user_data_bastion.rendered}"


#   security_groups = ["${aws_security_group.bastion.id}"]
#   key_name        = "${aws_key_pair.instance.key_name}"


#   lifecycle {
#     create_before_destroy = true
#   }
# }


# resource "aws_autoscaling_group" "bastion" {
#   name                 = "${var.name}-${var.env}-bastion-asg"
#   launch_configuration = "${aws_launch_configuration.bastion.name}"


#   max_size            = "1"
#   min_size            = "1"
#   desired_capacity    = "1"
#   vpc_zone_identifier = ["${aws_subnet.public.*.id}"]


#   lifecycle {
#     create_before_destroy = true
#   }
# }

