resource "aws_cloudwatch_event_rule" "closes_night_bst" {
    name                = "Office-closes-night-BST"
    description         = "Closing time at 7pm"
    schedule_expression = "cron(01 18 ? * 1-7 *)"

    tags = {
        Environment = var.environment
        Service     = var.service
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_cloudwatch_event_target" "closes_night_bst" {
    rule      = aws_cloudwatch_event_rule.closes_night_bst.name
    target_id = "lambda"
    arn       = aws_lambda_function.out_of_hours_shutdown.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_closes_night_bst" {
    statement_id  = "AllowClosesNightBSTExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.out_of_hours_shutdown.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.closes_night_bst.arn
}

resource "aws_cloudwatch_event_rule" "closes_night" {
    name                = "Office-closes-night"
    description         = "Closing time at 7pm"
    schedule_expression = "cron(01 19 ? * 1-7 *)"

    tags = {
        Environment = var.environment
        Service     = var.service
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_cloudwatch_event_target" "closes_night" {
    rule      = aws_cloudwatch_event_rule.closes_night.name
    target_id = "lambda"
    arn       = aws_lambda_function.out_of_hours_shutdown.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_closes_night" {
    statement_id  = "AllowClosesNightExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.out_of_hours_shutdown.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.closes_night.arn
}

resource "aws_cloudwatch_event_rule" "opens_morning_bst" {
    name                = "Office-opens-morning-BST"
    description         = "Opening time at 8am"
    schedule_expression = "cron(01 7 ? * MON-FRI *)"

    tags = {
        Environment = var.environment
        Service     = var.service
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_cloudwatch_event_target" "opens_morning_bst" {
    rule      = aws_cloudwatch_event_rule.opens_morning_bst.name
    target_id = "lambda"
    arn       = aws_lambda_function.out_of_hours_shutdown.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_opens_morning_bst" {
    statement_id  = "AllowOpenMorningBSTExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.out_of_hours_shutdown.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.opens_morning_bst.arn
}

resource "aws_cloudwatch_event_rule" "opens_morning" {
    name                = "Office-opens-morning"
    description         = "Opening time at 8am"
    schedule_expression = "cron(01 8 ? * MON-FRI *)"

    tags = {
        Environment = var.environment
        Service     = var.service
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_cloudwatch_event_target" "opens_morning" {
    rule      = aws_cloudwatch_event_rule.opens_morning.name
    target_id = "lambda"
    arn       = aws_lambda_function.out_of_hours_shutdown.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_opens_morning" {
    statement_id  = "AllowOpenMorningExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.out_of_hours_shutdown.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.opens_morning.arn
}
