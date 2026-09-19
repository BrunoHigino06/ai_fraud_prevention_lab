variable "iam_role" {
  type                  = map(object({
    name                = string
    assume_role_policy  = string
  }))
}