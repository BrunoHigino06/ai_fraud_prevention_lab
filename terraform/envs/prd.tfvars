lambda_function = {
  "backend_service" = {
    function_name          = "backend_service"
    role                   = "backend_execution_role"
    handler                = "backend_service.handler"
    runtime                = "python3.15"
    publish                = true
    filename               = "backend_service.zip"
    environment_variables  = {
      GLUE_JOB_NAME = "transaction_masking_job"
    }
  }
}