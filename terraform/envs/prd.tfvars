lambda_function = {
  "backend_service" = {
    function_name          = "backend_service"
    role                   = "lambda_execution_role"
    handler                = "backend_service.handler"
    runtime                = "python3.15"
    publish                = true
    filename               = "backend_service.zip"
    environment_variables  = {
      GLUE_JOB_NAME = "transaction_normalization_job"
    }
  },
  "fraud_detection" = {
    function_name          = "fraud_detection"
    role                   = "lambda_execution_role"
    handler                = "fraud_detection.handler"
    runtime                = "python3.15"
    publish                = true
    filename               = "fraud_detection.zip"
    environment_variables  = {
      AGENT_ID             = "transaction_masking_job"
      AGENT_ALIAS_ID       = ""
    }
  }
}

iam_policy = {
  "lambda_execution_policy" = {
    name        = "lambda_execution_policy"
    description = "Policy for Lambda execution role"
    policy      = "lambda_execution_policy.json"
  },
  "glue_execution_policy" = {
    name        = "glue_execution_policy"
    description = "Policy for Glue execution role"
    policy      = "glue_execution_policy.json"
  },
  "bedrockagent_agent_policy" = {
    name        = "bedrockagent_agent_policy"
    description = "Policy for Bedrock Agent role"
    policy      = "bedrockagent_agent_policy.json"
  },
  "step_function_policy" = {
    name        = "step_functions_policy"
    description = "Policy for Step Function Agent role"
    policy      = "step_function_policy.json"
  }
}

iam_role = {
  "lambda_execution_role" = {
    name                = "lambda_execution_role"
    assume_role_policy  = "lambda_assume_role_policy.json"
  },
  "glue_execution_role" = {
    name                = "glue_execution_role"
    assume_role_policy  = "glue_assume_role_policy.json"
  },
  "bedrockagent_agent_role" = {
    name                = "bedrockagent_agent_role"
    assume_role_policy  = "bedrockagent_agent_assume_role_policy.json"
  },
  "step_function_role" = {
    name                = "step_function_role"
    assume_role_policy  = "step_function_assume_role_policy.json"
  }
  
}

glue_job = {
  "transaction_normalization_job" = {
    name                  = "transaction_normalization_job"
    description           = "Normalizer glue job"
    glue_execution_role   = "glue_execution_role"
    glue_version          = "5.0"
    max_concurrent_runs   = 1
    number_of_workers     = 1
    worker_type           = "G.1X"
    s3_bucket             = "script_bucket"
    command               = {
      name                = "glueetl"
      script_location     = "s3://my-bucket/scripts/transaction_normalization.py"
      python_version      = "3"
    }
    default_arguments     = {
      "--users_table_name"        = "user_table"
      "--transactions_table_name" = "transaction_table"
      "fraud_results_table_name"  = "fraud_results_table"
    }
    max_retries           = 0
    timeout               = 2880
  }
}

dynamodb_table = {
  "user_table" = {
    name          = "user_table"
    hash_key      = "user_name"
    hash_key_type = "N"
  },
  "transaction_table" = {
    name          = "transaction_table"
    hash_key      = "user_id"
    hash_key_type = "N"
  },
  "fraud_results_table" = {
    name          = "fraud_results_table"
    hash_key      = "result_id"
    hash_key_type = "N"
  }
}

bedrockagent_agent = {
  "fraud_detection_agent"    = {
    agent_name               = "fraud_detection_agent"
    agent_resource_role_name = "bedrockagent_agent_role"
    foundation_model         = "anthropic.claude-v2"
    description              = "Agent for fraud detection using Bedrock"
  }
}

bedrockagent_alias = {
  "fraud_detection_agent_alias" = {
    agent_name               = "fraud_detection_agent"
    alias_name               = "fraud_detection_agent_alias"
    description              = "Alias for fraud detection agent"
  }
}

bedrockagent_agent_action_group = {
  "fraud_detection_action_group" = {
    action_group_name = "fraud_detection_action_group"
    agent_name        = "fraud_detection_agent"
    agent_version     = "1.0"
    description       = "Action group for fraud detection agent"
    lambda_name       = "fraud_detection"
    functions         = {
      "detect_fraud"  = {
        function_name = "detect_fraud"
        description   = "Function to detect fraudulent transactions"
        parameters    = {
          "transaction_id" = {
            map_block_key = "transaction_id"
            type          = "string"
            description   = "The ID of the transaction to analyze"
            required      = true
          },
          "user_id" = {
            map_block_key = "user_id"
            type          = "string"
            description   = "The ID of the user associated with the transaction"
            required      = true
          }
        }
      }
    }
  }
}

table_itens = {
  user_table = {
    table_name = "user_table"
    file_name  = "user_table.json"
    hash_key   = "user_name"
  },
  transaction_table = {
    table_name = "transaction_table"
    file_name  = "transaction_table.json"
    hash_key   = "user_id"
  },
  fraud_results_table = {
    table_name = "fraud_results_table"
    file_name  = "fraud_results_table.json"
    hash_key   = "result_id"
  }
}