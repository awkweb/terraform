resource "aws_ecs_cluster" "instance" {
  name = "${var.name}-${var.env}"
}

resource "aws_ecs_task_definition" "api" {
  family                = "${var.name}-${var.env}-api"
  container_definitions = "${data.template_file.api_container_definition.rendered}"
}

resource "aws_ecs_task_definition" "db_migrate" {
  family                = "${var.name}-${var.env}-db-migrate"
  container_definitions = "${data.template_file.db_migrate_container_definition.rendered}"
}

resource "aws_ecs_service" "api" {
  name                               = "api"
  cluster                            = "${aws_ecs_cluster.instance.id}"
  task_definition                    = "${aws_ecs_task_definition.api.arn}"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  iam_role                           = "${aws_iam_role.ecs.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.instance.arn}"
    container_name   = "nginx"
    container_port   = 80
  }
}

resource "aws_ecs_service" "db_migrate" {
  name            = "db-migrate"
  cluster         = "${aws_ecs_cluster.instance.id}"
  task_definition = "${aws_ecs_task_definition.db_migrate.arn}"
}

resource "aws_appautoscaling_target" "instance" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.instance.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.autoscale.arn}"
  min_capacity       = 2
  max_capacity       = 4
}

resource "aws_appautoscaling_policy" "up" {
  name               = "${var.name}-${var.env}-scale-up"
  service_namespace  = "${aws_appautoscaling_target.instance.service_namespace}"
  resource_id        = "service/${aws_ecs_cluster.instance.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.instance"]
}

resource "aws_appautoscaling_policy" "down" {
  name               = "${var.name}-${var.env}-scale-down"
  service_namespace  = "${aws_appautoscaling_target.instance.service_namespace}"
  resource_id        = "service/${aws_ecs_cluster.instance.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.instance"]
}
