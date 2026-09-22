module "bedrockagent_agent" {
  source = "./modules/bedrockagent_agent"

  bedrockagent_agent = {
    for bedrockagent_agent in var.bedrockagent_agent : bedrockagent_agent => {
      agent_name              = bedrockagent_agent.agent_name
      agent_resource_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${bedrockagent_agent.agent_resource_role_name}"
      foundation_model        = bedrockagent_agent.foundation_model
      description             = bedrockagent_agent.description
      tags                    = var.tags
    }
  }
}

module "bedrockagent_alias" {
  source = "./modules/bedrockagent_alias"

  bedrockagent_alias = {
    for bedrockagent_alias in var.bedrockagent_alias : bedrockagent_alias => {
      alias_name = bedrockagent_alias.alias_name
      agent_id   = bedrockagent_alias.agent_id
    }
  }
}

module "bedrockagent_action_group" {
  source = "./modules/bedrockagent_agent_action_group"

  bedrockagent_agent_action_group = {
    for bedrockagent_agent_action_group in var.bedrockagent_agent_action_group : bedrockagent_agent_action_group => {
      action_group_name = bedrockagent_agent_action_group.value.action_group_name
      agent_id          = bedrockagent_agent_action_group.value.agent_id
      agent_version     = bedrockagent_agent_action_group.value.agent_version
      description       = bedrockagent_agent_action_group.value.description
      lambda_arn        = bedrockagent_agent_action_group.value.lambda_arn
        functions = {
          for function in bedrockagent_agent_action_group.value.functions : function => {
            function_name = function.value.function_name
            description   = function.value.description
            parameters = {
              for parameter in function.value.parameters : parameter => {
                map_block_key = parameter.value.map_block_key
                type          = parameter.value.type
                description   = parameter.value.description
                required      = parameter.value.required
              }
            }
          }
        }
    }
  }
}
