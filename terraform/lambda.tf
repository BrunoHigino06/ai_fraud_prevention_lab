module "lambda_function" {
  source = "./modules/lambda"

  lambda_function = {
    for key, lambda_function in var.lambda_function : key => {
      function_name          = lambda_function.function_name
      role                   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${lambda_function.role}"
      handler                = lambda_function.handler
      runtime                = lambda_function.runtime
      publish                = lambda_function.publish
      filename               = "./scripts/lambda/${lambda_function.filename}"
      environment_variables  = lambda_function.environment_variables
      tags                   =  local.tags
    }
  }
  depends_on = [
    module.iam_role, 
    module.iam_policy
  ]
}