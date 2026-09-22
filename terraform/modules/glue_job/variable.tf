variable "glue_job" {
  type                  = map(object({
    name                = string
    description         = string
    role_arn            = string
    glue_version        = string
    max_retries         = number
    timeout             = number
    number_of_workers   = number
    worker_type         = string
    s3_bucket           = string
    max_concurrent_runs = number
    tags                = map(string)
  }))
}