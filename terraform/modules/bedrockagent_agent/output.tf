output "agent_id" {
  value = {
    for key, agent in aws_bedrockagent_agent.bedrockagent_agent :
    key => agent.agent_id
  }
}