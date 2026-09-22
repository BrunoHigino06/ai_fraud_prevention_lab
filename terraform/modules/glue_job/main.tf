resource "aws_glue_job" "glue_job" {
  for_each          = var.glue_job 
  name              = each.value.name
  description       = each.value.description
  role_arn          = each.value.role_arn
  glue_version      = each.value.glue_version
  max_retries       = each.value.max_retries
  timeout           = each.value.timeout
  number_of_workers = each.value.number_of_workers
  worker_type       = each.value.worker_type
  execution_class   = "STANDARD"

  command {
    script_location = "s3://${each.value.s3_bucket}/jobs/${each.value.name}.py"
    name            = each.value.name
    python_version  = "3"
  }

  notification_property {
    notify_delay_after = 3 # delay in minutes
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = "/aws-glue/jobs"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--enable-auto-scaling"              = "true"
  }

  execution_property {
    max_concurrent_runs = each.value.max_concurrent_runs
  }

  tags = var.glue_job.tags
}