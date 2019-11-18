resource "aws_alb" "main" {
  name            = var.project
  subnets         = aws_subnet.public[*].id
  security_groups = [aws_security_group.lb.id]
  tags = {
    Project = var.project
  }
}

resource "aws_alb_target_group" "app" {
  name        = var.project
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  tags = {
    Project = var.project
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }

}
