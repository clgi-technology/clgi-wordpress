output "lambda_function_name" {
  description = "Lambda function that performs auto-delete"
  value       = aws_lambda_function.auto_delete_lambda.function_name
}
