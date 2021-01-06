data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda"
    output_path = "lambda-function.zip"
}

resource "aws_iam_role" "out_of_hours_shutdown_lambda_role" {
    name = "out_of_hours_shutdown_lambda_role"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

    tags = {
        Environment = var.environment
        Service     = var.service
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_iam_role_policy" "out_of_hours_shutdown_lambda_role_policy" {
    name = "out_of_hours_shutdown_lambda_role_policy"
    role = aws_iam_role.out_of_hours_shutdown_lambda_role.id

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "autoscaling:ResumeProcesses",
                "autoscaling:SuspendProcesses",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*",
                "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*",
                "arn:aws:autoscaling:*:*:launchConfiguration:*:launchConfigurationName/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingNotificationTypes",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeScalingProcessTypes",
                "autoscaling:DescribeTerminationPolicyTypes",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeAdjustmentTypes",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeAccountLimits",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeLoadBalancerTargetGroups",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:DescribeLifecycleHookTypes",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeMetricCollectionTypes",
                "autoscaling:DescribeLoadBalancers",
                "autoscaling:DescribeLifecycleHooks",
                "ec2:DescribeInstances",
                "ec2:Start*",
                "ec2:Stop*",
                "rds:Describe*",
                "rds:StopDBInstance",
                "rds:StartDBInstance",
                "rds:ListTagsForResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_lambda_function" "out_of_hours_shutdown" {
    filename         = "lambda-function.zip"
    function_name    = "out-of-hours-shutdown"
    role             = aws_iam_role.out_of_hours_shutdown_lambda_role.arn
    handler          = "out_of_hours_shutdown.handler"
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    runtime          = "python3.6"

    tags = {
        Environment = var.environment
        Service     = var.service
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}