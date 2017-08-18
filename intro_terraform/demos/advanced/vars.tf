variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = ""
}

variable "vpc_cidr" {}

variable "tcp_9999_cidrs" {
  type = "list"
}

variable "ssh_key_name" {}

variable "ssh_public_key" {}

variable "nodes" {
  default = 1
}

variable "instance_type" {
  default = "t2.nano"
}
