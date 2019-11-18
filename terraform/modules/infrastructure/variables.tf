variable project {}
variable vpc_cidr {}
variable "az_count" {}
variable "app_port" {}
variable "app_count" {}
variable "db_name" {}
variable "db_user" {}
variable "db_pass" {}
variable "tag" {}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "fargate_cpu" {
  default = "256"
}
variable "fargate_memory" {
  default = "512"
}
