variable "glue_catalog_database" {
  type          = map(object({
    name        = string
    description = string
    tags        = map(string)
  }))
}