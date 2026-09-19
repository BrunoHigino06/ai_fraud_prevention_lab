variable "bedrockagent_agent_action_group" {
  type = map(object({
    action_group_name = string
    agent_id          = string
    agent_version     = string
    description       = string
    lambda_arn        = string
    functions         = map(object({
        function_name = string
        description   = string
        parameters    = map(object({
            map_block_key = string
            type          = string
            description   = string
            required      = bool
        }))
    }))
  }))
}