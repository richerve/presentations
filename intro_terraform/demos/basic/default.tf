#### VPC #####

resource "aws_vpc" "main" {
  cidr_block           = "192.168.1.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "test"
    Provisioner = "terraform"
  }
}

##### Subnets #####

resource "aws_subnet" "2a" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "192.168.1.0/26"
  availability_zone = "us-east-2a"

  tags {
    Name        = "test-us-east-2a"
    Provisioner = "terraform"
  }
}

resource "aws_subnet" "2b" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "192.168.1.64/26"
  availability_zone = "us-east-2b"

  tags {
    Name        = "test-us-east-2b"
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
  cidr_blocks       = ["192.168.15.39/32"]
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
  key_name   = "test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkSHvlYojyNIqLUp8has2Y1Tp18v75z9mgs3EB0YetxT31eNPakKKixZ1n5KN6ASRLW/OVaOrBdYRuMzen5sNW22ZiTdGVsyGVvV4gkJshaZ5Oqd6gfrVhS1F/jRilj68Rhw4ryAcf+VADKab3+TI71PiYGuZDEOjgsHdO7DsBgZ9bvLHGZw9hs6bc8kbEZJpyxcj92YfVmiXcxNPHBMsyPKOZJcy4cEE7M8QqLQ8YYZ6i+zcCVo6oHSIB2TeXzpR/IJ5Qhkd6szB7PwFDd91kE/ixiRwkKQNdYo9qo23LvXRboQRRGNA3pNMiFiA+MhfqvhRc4CRyo49PGsAZc0EX"
}

##### Instance #####

resource "aws_instance" "main" {
  ami                    = "ami-dbbd9dbe"
  instance_type          = "t2.nano"
  key_name               = "${aws_key_pair.main.key_name}"
  subnet_id              = "${aws_subnet.2a.id}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  root_block_device {
    volume_size = 10
  }

  tags {
    Name        = "test"
    Provisioner = "terraform"
  }
}
