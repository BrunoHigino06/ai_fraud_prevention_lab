module "iam_policy" {
  source = "./modules/iam_policy"

  iam_policy = {
    for key, iam_policy in var.iam_policy : key => {
      name        = iam_policy.name
      description = iam_policy.description
      policy_file = file("${path.module}/templates/iam/${iam_policy.policy}",)
    }
  }
}

module "iam_role" {
  source = "./modules/iam_role"

  iam_role = {
    for key, iam_role in var.iam_role : key => {
      name                = iam_role.name
      assume_role_policy  = file("${path.module}/templates/iam/${iam_role.assume_role_policy}")
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = var.iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.iam_policy.lambda_execution_policy.name}"

  depends_on = [
    module.iam_role,
    module.iam_policy
  ]
}

resource "aws_iam_role_policy_attachment" "glue_execution_policy_attachment" {
  role       = var.iam_role.glue_execution_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.iam_policy.glue_execution_policy.name}"

  depends_on = [
    module.iam_role,
    module.iam_policy
  ]
}

resource "aws_iam_role_policy_attachment" "bedrockagent_agent_policy_attachment" {
  role       = var.iam_role.bedrockagent_agent_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.iam_policy.bedrockagent_agent_policy.name}"

  depends_on = [
    module.iam_role,
    module.iam_policy
  ]
}