terraform {
  cloud {
    organization = "terraform_test3141"

    workspaces {
      name = "local_tf_code"
    }
  }
}
