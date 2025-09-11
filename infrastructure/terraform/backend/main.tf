resource "b2_bucket" "parent_backend_bucket" {
  bucket_name = "self-hosted-terraform-backend"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}
