variable "bedrockagent_agent_alias" {
  type = map(object({
    agent_alias_name = string
    agent_id         = string
    description      = string
    tags             = map(string)
  }))
}