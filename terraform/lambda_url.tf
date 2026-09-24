resource "aws_lambda_function_url" "backend_service_url" {
  function_name      = module.lambda_function.lambda_function["backend_service"].function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["POST", "GET", "OPTIONS"]
    allow_headers     = ["content-type"]
    max_age           = 600
  }
}
