module "glue_jobs" {
  source = "./modules/glue_jobs"

  glue_job = {
    for glue_job in var.glue_job : glue_job => {
      name                = glue_job.name
      description         = glue_job.description
      role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${glue_execution_role.role}"
      glue_version        = glue_job.glue_version
      max_retries         = glue_job.max_retries
      timeout             = glue_job.timeout
      number_of_workers   = glue_job.number_of_workers
      worker_type         = glue_job.worker_type
      s3_bucket           = glue_job.s3_bucket
      max_concurrent_runs = glue_job.max_concurrent_runs
      tags                = var.tags
    }
  }
}