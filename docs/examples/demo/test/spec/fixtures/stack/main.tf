resource "random_pet" "name_prefix" {
  length = 1
}

module "example" {
  source = "../../modules/example"

  project     = "<%= ENV['GOOGLE_PROJECT'] %>"
  region      = "<%= ENV['GOOGLE_REGION'] %>"

  name_prefix = random_pet.name_prefix.id
}
