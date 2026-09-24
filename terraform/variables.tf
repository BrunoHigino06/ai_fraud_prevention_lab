variable "iam_policy" {
  type = map(object({
    name        = string
    description = string
    policy      = string
  }))
}

variable "iam_role" {
  type = map(object({
    name               = string
    assume_role_policy = string
  }))
}
variable "lambda_function" {
  type = map(object({
    function_name         = string
    role                  = string
    handler               = string
    runtime               = string
    publish               = bool
    filename              = string
    environment_variables = map(string)
  }))
}
variable "glue_job" {
  type = map(object({
    name                = string
    description         = string
    glue_execution_role = string
    glue_version        = string
    max_retries         = number
    timeout             = number
    number_of_workers   = number
    worker_type         = string
    max_concurrent_runs = number
    s3_bucket           = string
  }))
}

variable "dynamodb_table" {
  type = map(object({
    name                     = string
    hash_key                 = string
    hash_key_type            = string
    range_key_type           = optional(string)
    attribute_range_key      = optional(string)
    attribute_range_key_type = optional(string)
    
  }))
}

variable "bedrockagent_agent" {
  type = map(object({
    agent_name               = string
    agent_resource_role_name = string
    foundation_model         = string
    description              = string
  }))
}

variable "bedrockagent_alias" {
  type = map(object({
    alias_name  = string
    agent_name  = string
    description = optional(string)
  }))
}

variable "bedrockagent_agent_action_group" {
  type = map(object({
    action_group_name = string
    agent_name        = string
    agent_version     = string
    description       = string
    lambda_name       = string
    functions = map(object({
      function_name = string
      description   = string
      parameters = map(object({
        map_block_key = string
        type          = string
        description   = string
        required      = bool
      }))
    }))
  }))
}

variable "table_itens" {
  type = map(object({
    table_name = string
    file_name  = string
    hash_key   = string
  }))
}
