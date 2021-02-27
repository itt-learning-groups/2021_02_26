# We'll start with just the provider. This won't create anything in AWS.
# But it will allow us to run `terraform init` and install the provider.
provider "aws" {
    region = "us-west-2"
}
