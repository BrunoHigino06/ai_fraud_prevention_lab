module "lambda_function" {
  source = "./modules/lambda"

  lambda_function = [
    for lambda_function in var.lambda_function : {
      function_name          = lambda_function.value.function_name
      role                   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${lambda_function.value.role}"
      handler                = lambda_function.value.handler
      runtime                = lambda_function.value.runtime
      publish                = lambda_function.value.publish
      filename               = lambda_function.value.filename
      environment_variables  = lambda_function.value.environment_variables
      tags                   = var.tags
    }
  ]
}