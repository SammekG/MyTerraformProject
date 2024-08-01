provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://13.233.140.113:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "c2cca9cf-700f-aef5-db62-e4f7f53182ee"
      secret_id = "ba375874-d3e5-882a-a2ee-f52b04f40ad1"
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv-secret" // change it according to your mount
  name  = "test-secret" // change it according to your secret
}

resource "aws_instance" "example" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"

  tags = {
    Name = "test"
    Secret = data.vault_kv_secret_v2.example.data["username"]
  }
}
