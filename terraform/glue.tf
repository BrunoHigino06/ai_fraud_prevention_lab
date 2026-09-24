module "glue_jobs" {
  source = "./modules/glue_job"

  glue_job = {
    for key, glue_job in var.glue_job : key => {
      name                = glue_job.name
      description         = glue_job.description
      role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${glue_job.glue_execution_role}"
      glue_version        = glue_job.glue_version
      max_retries         = glue_job.max_retries
      timeout             = glue_job.timeout
      number_of_workers   = glue_job.number_of_workers
      worker_type         = glue_job.worker_type
      max_concurrent_runs = glue_job.max_concurrent_runs
      s3_bucket           = aws_s3_bucket.glue_bucket.bucket
      tags                = local.tags
    }
  }

  depends_on = [
    aws_s3_bucket.glue_bucket,
    module.iam_policy,
    module.iam_role
  ]
}