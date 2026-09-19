variable "iam_policy" {
  type          = map(object({
    name        = string
    description = string
    policy_file = string
  }))
}