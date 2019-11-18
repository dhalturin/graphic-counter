resource "aws_iam_role" "ecs" {
  name               = "ecs_role"
  assume_role_policy = file("${path.module}/policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs" {
  name   = "ecs_policy"
  policy = file("${path.module}/policies/ecs-policy.json")
  role   = aws_iam_role.ecs.id
}

