variable "lambda_function" {
  type = map(object({
    function_name          = string
    role                   = string
    handler                = string
    runtime                = string
    publish                = bool
    filename               = string
    environment_variables  = map(string)
    tags                   = map(string)
  }))
}