# Provider
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

##### Variables #####

# A better way to get a list of azs is using a data source: https://www.terraform.io/docs/providers/aws/d/availability_zones.html
variable "azs" {
  type    = "list"
  default = ["a", "b", "c", "d", "e", "f"]
}

# There are other variable definitions on the main.tfvars file

#### VPC #####

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "test"
    Provisioner = "terraform"
  }
}

# Tag default route table
resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  tags {
    Name        = "test"
    Provisioner = "terraform"
  }
}

##### Subnets #####

resource "aws_subnet" "main" {
  count             = 3
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 2, count.index)}"
  availability_zone = "us-east-2${var.azs[count.index]}"

  tags {
    Name        = "test-us-east-2${element(var.azs, count.index)}"
    Provisioner = "terraform"
  }
}

##### Security group #####

resource "aws_security_group" "sg" {
  name        = "test-sg"
  vpc_id      = "${aws_vpc.main.id}"
  description = "A security group for testing"

  tags {
    Name        = "test-sg"
    Provisioner = "terraform"
  }
}

resource "aws_security_group_rule" "in_tcp_9999" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "9999"
  to_port           = "9999"
  cidr_blocks       = "${var.tcp_9999_cidrs}"
  security_group_id = "${aws_security_group.sg.id}"
}

resource "aws_security_group_rule" "out_all" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg.id}"
}

##### SSH Key #####

resource "aws_key_pair" "main" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.ssh_public_key}"
}

##### Instance #####

data "aws_ami" "ubuntu_1604_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

resource "aws_instance" "main" {
  count                  = "${var.nodes}"
  ami                    = "${data.aws_ami.ubuntu_1604_latest.image_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.main.key_name}"
  subnet_id              = "${element(aws_subnet.main.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  root_block_device {
    volume_size = 10
  }

  tags {
    Name        = "test-${count.index}"
    Provisioner = "terraform"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }
}
