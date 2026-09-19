resource "aws_bedrockagent_agent" "bedrockagent_agent" {
  for_each                = var.bedrockagent_agent  
  agent_name              = each.value.agent_name
  agent_resource_role_arn = each.value.role_arn
  foundation_model        = each.value.foundation_model
  description             = each.value.description
  tags                    = var.bedrockagent_agent.tags
}