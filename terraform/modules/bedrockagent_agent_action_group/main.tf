resource "aws_bedrockagent_agent_action_group" "bedrockagent_agent_action_group" {
  for_each          = var.bedrockagent_agent_action_group
  action_group_name = each.value.action_group_name
  agent_id          = each.value.agent_id
  agent_version     = each.value.agent_version
  description       = each.value.description  

  action_group_executor {
    lambda = each.value.lambda_arn
  }

  function_schema {
    member_functions {
        dynamic "functions" {
            for_each = each.value.functions
            content {
                name        = functions.value.function_name
                description = functions.value.description
                dynamic "parameters" {
                    for_each = functions.value.parameters
                    content {
                        map_block_key = parameters.value.map_block_key
                        type          = parameters.value.type
                        description   = parameters.value.description
                        required      = parameters.value.required
                    }
                }
            }
        }
    }
  }
}