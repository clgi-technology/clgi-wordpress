terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ChurchoftheLivingGodIntlInc"

    workspaces {
      name = "clgi-wordpress-aws"
    }
  }
}
