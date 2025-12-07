# Application Load Balancer
resource "aws_lb" "this" {
  name               = "${lookup(var.tags, "Project", "terraform")}-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = var.subnet_ids
  security_groups = var.security_group_ids

  tags = merge(
    var.tags,
    {
      Name      = "${lookup(var.tags, "Project", "terraform")}-alb"
      Component = "load-balancer"
    }
  )
}

# Target Group
resource "aws_lb_target_group" "this" {
  name     = "${lookup(var.tags, "Project", "terraform")}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    var.tags,
    {
      Name      = "${lookup(var.tags, "Project", "terraform")}-tg"
      Component = "web"
    }
  )
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "this" {
  count = length(var.target_instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.target_port
}


# HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
