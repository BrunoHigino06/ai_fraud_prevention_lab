resource aws_lambda_function "lambda_function" {
  for_each         = var.lambda_function
  function_name    = each.value.function_name
  role             = each.value.role
  handler          = each.value.handler
  runtime          = each.value.runtime
  publish          = each.value.publish  
  filename         = each.value.filename
  source_code_hash = filebase64sha256(each.value.filename)
  tags             = var.lambda_function.tags  
  environment {
    variables = each.value.environment_variables
  }  
}
