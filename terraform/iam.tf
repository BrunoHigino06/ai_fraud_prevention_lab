module "iam_policy" {
  source = "./modules/iam_policy"

  iam_policy = {
    for iam_policy in var.iam_policy : iam_policy => {
      name        = iam_policy.name
      description = iam_policy.description
      policy      = iam_policy.policy
    }
  }
}

module "iam_role" {
  source = "./modules/iam_role"

  iam_role = {
    for iam_role in var.iam_role : iam_role => {
      name                = iam_role.name
      assume_role_policy  = iam_role.assume_role_policy
    }
  }
}