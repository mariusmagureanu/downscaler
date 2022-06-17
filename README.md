k8s cluster downscaler
----------------------

This project is a poor man's attempt to reduce cost with running clusters. The idea behind it is to automatically scale up/down the number of worker nodes.
It is assumed that the clusters are used within certain time frames, thus not being needed outside them, e.g. evenings,weekends...etc

## What is it?

The downscaler is a lambda function triggered at specific times. There are two available schedules to be set, one for upscaling and another for downscaling.

## Build the downscaler

Run the following in the repository's root directory:

```sh
$ make
```

This will build the lambda source code under ``src/`` and create a ``source.zip`` file.

## Deploy the downscaler

The terraform code associated with the entire infra is found in the ``terraform`` directory.

Make sure you have the correct AWS credentials in place, fill in the variables as needed and proceed to ``apply``.

#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.18.0 |

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.18.0 |

#### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.asg_down_scale_rule](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.asg_up_scale_rule](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.asg_down_scale_target](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.asg_up_scale_target](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.autoscaling_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ec2_autoscaling_event_role](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.autoscaling_lifecycle_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloud_watch_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.asg_scale_function](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.downscale_allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.upscale_allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/resources/lambda_permission) | resource |
| [aws_autoscaling_groups.current_groups](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/data-sources/autoscaling_groups) | data source |
| [aws_iam_policy_document.instance_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/4.18.0/docs/data-sources/iam_policy_document) | data source |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster used for detecting the attached autoscaling-groups. | `string` | n/a | yes |
| <a name="input_lambda_file"></a> [lambda\_file](#input\_lambda\_file) | n/a | `string` | n/a | yes |
| <a name="input_scale_down_max_size"></a> [scale\_down\_max\_size](#input\_scale\_down\_max\_size) | Max capacity after a scale down. | `number` | `1` | no |
| <a name="input_scale_down_schedule"></a> [scale\_down\_schedule](#input\_scale\_down\_schedule) | Set the down scaling schedule. (expressed in UTC) | `string` | `"cron(0 15 ? * MON-FRI *)"` | no |
| <a name="input_scale_in_protection"></a> [scale\_in\_protection](#input\_scale\_in\_protection) | Enable scale-in protection for new nodes after scale up. | `bool` | `false` | no |
| <a name="input_scale_up_max_size"></a> [scale\_up\_max\_size](#input\_scale\_up\_max\_size) | Max capacity after a scale up. | `number` | `10` | no |
| <a name="input_scale_up_schedule"></a> [scale\_up\_schedule](#input\_scale\_up\_schedule) | Set the up scaling schedule. (expressed in UTC) | `string` | `"cron(0 6 ? * MON-FRI *)"` | no |
