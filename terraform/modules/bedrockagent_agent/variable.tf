variable "bedrockagent_agent" {
  type                      = map(object({
    agent_name              = string
    description             = string
    agent_resource_role_arn = string
    foundation_model        = string
    tags                    = map(string)
  }))
}