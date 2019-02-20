output "lb_zone_id" {
  value = "${aws_alb.instance.zone_id}"
}

output "lb_dns_name" {
  value = "${aws_alb.instance.dns_name}"
}

output "lb_security_group_id" {
  value = "${aws_security_group.instance.id}"
}

output "lb_target_group_arn" {
  value = "${aws_alb_target_group.instance.arn}"
}
