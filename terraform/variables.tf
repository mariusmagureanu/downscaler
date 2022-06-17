variable "cluster_name" {
  type        = string
  description = "Name of the cluster used for detecting the attached autoscaling-groups."
}

variable "scale_up_schedule" {
  type        = string
  description = "Set the up-scaling schedule. (expressed in UTC)"
  default     = "cron(0 6 ? * MON-FRI *)"
}

variable "scale_down_schedule" {
  type        = string
  description = "Set the down-scaling schedule. (expressed in UTC)"
  default     = "cron(0 15 ? * MON-FRI *)"
}

variable "scale_up_max_size" {
  type        = number
  description = "Max capacity after a scale-up."
  default     = 10
}

variable "scale_down_max_size" {
  type        = number
  description = "Max capacity after a scale-down."
  default     = 1

}

variable "scale_in_protection" {
  type        = bool
  description = "Enable scale-in protection for new nodes after scale up."
  default     = false
}


variable "lambda_file" {
  type        = string
  description = "Path to the zip file containing the lambda function. (see scaler.zip)"
}
