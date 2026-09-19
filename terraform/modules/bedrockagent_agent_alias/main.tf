resource "aws_bedrockagent_agent_alias" "bedrockagent_agent_alias" {
  for_each         = var.bedrockagent_agent_alias
  agent_alias_name = each.value.agent_alias_name
  agent_id         = each.value.agent_id
  description      = each.value.description
  tags             = var.bedrockagent_agent_alias.tags
}