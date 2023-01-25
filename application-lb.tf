resource "aws_alb" "application_load_balancer" {
  name               =  "${var.project-prefix}-lb-${format("%s", terraform.workspace)}" # Nome do Load Balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${lookup(var.subnets-ids-az-a, terraform.workspace)}",
    "${lookup(var.subnets-ids-az-b, terraform.workspace)}",
    "${lookup(var.subnets-ids-az-c, terraform.workspace)}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_lb_target_group" "target_group" {
  name        =  "${var.project-prefix}-tg-${format("%s", terraform.workspace)}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${var.vpc-id}" # Referencing the default VPC

  health_check {
    path = "/status"
    port = 3333
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" # Referencing our load balancer
  port              = "3333"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our tagrte group
  }
}