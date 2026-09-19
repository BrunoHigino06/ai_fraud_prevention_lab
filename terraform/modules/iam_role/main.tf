resource "aws_iam_role" "iam_role" {
  for_each           = var.iam_role
  name               = each.value.name
  assume_role_policy = each.value.assume_role_policy
}