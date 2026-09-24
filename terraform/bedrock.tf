module "bedrockagent_agent" {
  source = "./modules/bedrockagent_agent"

  bedrockagent_agent = {
    for key, bedrockagent_agent in var.bedrockagent_agent : key => {
      agent_name              = bedrockagent_agent.agent_name
      agent_resource_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${bedrockagent_agent.agent_resource_role_name}"
      foundation_model        = bedrockagent_agent.foundation_model
      description             = bedrockagent_agent.description
      tags                    = local.tags
    }
  }
}

module "bedrockagent_alias" {
  source = "./modules/bedrockagent_agent_alias"

  bedrockagent_agent_alias = {
    for key, bedrockagent_alias in var.bedrockagent_alias : key => {
      agent_alias_name = bedrockagent_alias.alias_name
      description      = bedrockagent_alias.description
      tags             = local.tags
      agent_id         = module.bedrockagent_agent.agent_id[bedrockagent_alias.agent_name]
    }
  }
}

module "bedrockagent_action_group" {
  source = "./modules/bedrockagent_agent_action_group"

  bedrockagent_agent_action_group = {
    for key, bedrockagent_agent_action_group in var.bedrockagent_agent_action_group : key => {
      action_group_name = bedrockagent_agent_action_group.action_group_name
      agent_id          = module.bedrockagent_agent.agent_id[bedrockagent_agent_action_group.agent_name]
      agent_version     = bedrockagent_agent_action_group.agent_version
      description       = bedrockagent_agent_action_group.description
      lambda_arn        = "arn:aws:lambda:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:function:${bedrockagent_agent_action_group.lambda_name}"
      functions = {
        for function_key, function in bedrockagent_agent_action_group.functions : function_key => {
          function_name = function.function_name
          description   = function.description
          parameters = {
            for parameter_key, parameter in function.parameters : parameter_key => {
              map_block_key = parameter.map_block_key
              type          = parameter.type
              description   = parameter.description
              required      = parameter.required
            }
          }
        }
      }
    }
  }
}
