output "function_arns" {
  value = { for k, fn in aws_lambda_function.this : k => fn.arn }
}

output "function_names" {
  value = { for k, fn in aws_lambda_function.this : k => fn.function_name }
}

output "function_invoke_arns" {
  value = { for k, fn in aws_lambda_function.this : k => fn.invoke_arn }
}
