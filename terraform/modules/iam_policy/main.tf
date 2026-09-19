resource "aws_iam_policy" "iam_policy" {
  for_each    = var.iam_policy
  name        = each.value.name
  description = each.value.description
  policy      = templatefile(each.value.policy_file, {})
}