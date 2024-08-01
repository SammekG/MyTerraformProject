provider "aws" {
  region = "ap-south-1"
}

import {
  id = "i-0fb90bca2ad747bd8"

  to = aws_instance.example
}