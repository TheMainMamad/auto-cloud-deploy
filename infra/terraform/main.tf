resource "arvan_iaas_abrak" "abrak_1" {
  region    = var.region
  flavor    = var.flavor
  name      = var.abrak_name
  disk_size = var.disk_size

  image {
    type = var.image_type
    name = var.image_name
  }
}
