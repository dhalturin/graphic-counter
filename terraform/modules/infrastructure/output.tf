output aws_availability_zones {
  value = data.aws_availability_zones.available
}

output aws_ecr_repository {
  value = data.aws_ecr_repository.repo
}

output aws_alb {
  value = aws_alb.main.dns_name
}
