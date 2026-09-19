resource "aws_glue_catalog_database" "glue_catalog_database" {
  for_each    = var.glue_catalog_database
  name        = each.value.name
  description = each.value.description
  tags        = var.glue_catalog_database.tags
}