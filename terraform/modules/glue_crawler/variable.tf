variable "glue_crawler" {
  type = map(object({
    name          = string
    database_name = string
    role          = string
    description   = string
    table_name    = string
    tags          = map(string)
  }))
}