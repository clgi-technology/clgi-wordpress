resource "aws_iam_role" "lambda_role" {
  name = "${var.vm_name}-auto-delete-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "terminate_instance" {
  name        = "${var.vm_name}-terminate-instance"
  description = "Allows termination of EC2 instance"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = ["ec2:TerminateInstances"],
      Effect = "Allow",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "terminate_instance_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.terminate_instance.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_auto_delete.py"
  output_path = "${path.module}/lambda_auto_delete.zip"
}

resource "aws_lambda_function" "auto_delete_lambda" {
  function_name = "${var.vm_name}-auto-delete"
  handler       = "lambda_auto_delete.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      INSTANCE_ID = var.instance_id
    }
  }
}

resource "aws_cloudwatch_event_rule" "auto_delete_timer" {
  name                = "${var.vm_name}-auto-delete-rule"
  schedule_expression = "rate(24 hours)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.auto_delete_timer.name
  target_id = "TerminateVM"
  arn       = aws_lambda_function.auto_delete_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_delete_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_delete_timer.arn
}
