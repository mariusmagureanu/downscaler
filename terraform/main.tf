data "aws_autoscaling_groups" "current_groups" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [var.cluster_name]
  }

  filter {
    name   = "tag:kubernetes.io/cluster/${var.cluster_name}"
    values = ["owned"]
  }
}

resource "aws_cloudwatch_event_rule" "asg_up_scale_rule" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  name                = "ASG-Scaler-up-${var.cluster_name}-${count.index}"
  schedule_expression = var.scale_up_schedule
  tags = {
    cluster = var.cluster_name
  }
  description = "This rule is used to notify an asg scale up."
}

resource "aws_cloudwatch_event_rule" "asg_down_scale_rule" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  name                = "ASG-Scaler-down-${var.cluster_name}-${count.index}"
  schedule_expression = var.scale_down_schedule
  tags = {
    cluster = var.cluster_name
  }
  description = "This rule is used to notify an asg scale down."
}

resource "aws_cloudwatch_event_target" "asg_up_scale_target" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  arn  = aws_lambda_function.asg_scale_function[count.index].arn
  rule = aws_cloudwatch_event_rule.asg_up_scale_rule[count.index].name
  input = jsonencode(
    {
      "group_name"          = data.aws_autoscaling_groups.current_groups.names[count.index],
      "scale_up_max_size"   = var.scale_up_max_size,
      "scale_down_max_size" = var.scale_down_max_size,
      "scale_in_protection" = var.scale_in_protection
      "scale_type"          = "UP"
    }
  )
}

resource "aws_cloudwatch_event_target" "asg_down_scale_target" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  arn  = aws_lambda_function.asg_scale_function[count.index].arn
  rule = aws_cloudwatch_event_rule.asg_down_scale_rule[count.index].name
  input = jsonencode(
    {
      "group_name"          = data.aws_autoscaling_groups.current_groups.names[count.index],
      "scale_up_max_size"   = var.scale_up_max_size,
      "scale_down_max_size" = var.scale_down_max_size,
      "scale_in_protection" = var.scale_in_protection
      "scale_type"          = "DOWN"
    }
  )
}

resource "aws_lambda_function" "asg_scale_function" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  function_name    = "ASG-Scaler-${var.cluster_name}-${count.index}"
  description      = "This lambda function scales in/out the ${data.aws_autoscaling_groups.current_groups.names[count.index]} group."
  role             = aws_iam_role.ec2_autoscaling_event_role.arn
  filename         = var.lambda_file
  source_code_hash = filebase64sha256(var.lambda_file)
  handler          = "main"
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 100

  tags = {
    cluster = var.cluster_name
  }
}

resource "aws_lambda_permission" "upscale_allow_cloudwatch" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  statement_id  = "UpscaleAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asg_scale_function[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.asg_up_scale_rule[count.index].arn
}

resource "aws_lambda_permission" "downscale_allow_cloudwatch" {
  count = length(data.aws_autoscaling_groups.current_groups.arns)

  statement_id  = "DownscaleAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asg_scale_function[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.asg_down_scale_rule[count.index].arn
}

resource "aws_iam_role" "ec2_autoscaling_event_role" {
  name               = "ASG-Scaler-${var.cluster_name}"
  description        = "Role used by the asg autoscaler lambda function"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloud_watch_policy_attachment" {
  role       = aws_iam_role.ec2_autoscaling_event_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "autoscaling_lifecycle_policy" {
  name        = "ASG-Scaler-${var.cluster_name}"
  path        = "/"
  description = "This policy allows inspecting autoscaling groups"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:UpdateAutoScalingGroup",
        ]
        Effect   = "Allow"
        Resource = data.aws_autoscaling_groups.current_groups.arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "autoscaling_lifecycle_policy_attachment" {
  role       = aws_iam_role.ec2_autoscaling_event_role.name
  policy_arn = aws_iam_policy.autoscaling_lifecycle_policy.arn
}
