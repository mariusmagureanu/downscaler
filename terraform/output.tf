output "autoscaling_groups" {
  value = data.aws_autoscaling_groups.current_groups.names
}